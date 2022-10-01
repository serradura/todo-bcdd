# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'To-do items management', :type => :request do
  let(:user) { create(:user) }

  def sign_in(user, password: '123456')
    post '/users/sign_in', params: {user: {email: user.email, password:}}

    expect(response).to redirect_to('/')

    follow_redirect!

    expect(response).to redirect_to('/todos/uncompleted')

    follow_redirect!
  end

  it 'creates a to-do and redirects to the uncompleted to-dos page' do
    sign_in(user)

    expect(response).to render_template('todos/list/uncompleted')
    expect(response.body).to include('Uncompleted (0)')
    expect(response.body).to include('Nothing to do.')

    post '/todos', params: {todo: {description: 'Buy milk'}}

    expect(response).to redirect_to('/todos/uncompleted')

    follow_redirect!

    expect(response).to render_template('todos/list/uncompleted')
    expect(response.body).to include('To-do successfully created.')
    expect(response.body).to include('Uncompleted (1)')
    expect(response.body).not_to include('Nothing to do.')
  end

  it 'completes a to-do and redirects to the completed to-dos page' do
    todo = create(:todo_item, user:)

    sign_in(user)

    expect(response).to render_template('todos/list/uncompleted')
    expect(response.body).to include('Uncompleted (1)')
    expect(response.body).not_to include('Nothing to do.')

    path_to_complete_todo = response.body.squish.match(%{(/todos/#{todo.id}/complete)})[1]

    put path_to_complete_todo

    expect(response).to redirect_to('/todos/completed')

    follow_redirect!

    expect(response).to render_template('todos/list/completed')
    expect(response.body).to include('The to-do has become completed.')
    expect(response.body).to include('Completed (1)')
  end

  it 'uncompletes a to-do and redirects to the uncompleted to-dos page' do
    todo = create(:todo_item, :completed, user:)

    sign_in(user)

    expect(response).to render_template('todos/list/uncompleted')
    expect(response.body).to include('Uncompleted (0)')
    expect(response.body).to include('Nothing to do.')
    expect(response.body).to include('/todos/completed')

    get '/todos/completed'

    expect(response).to render_template('todos/list/completed')
    expect(response.body).to include('Completed (1)')

    path_to_uncomplete_todo = response.body.squish.match(%{(/todos/#{todo.id}/uncomplete)})[1]

    put path_to_uncomplete_todo

    expect(response).to redirect_to('/todos/uncompleted')

    follow_redirect!

    expect(response).to render_template('todos/list/uncompleted')
    expect(response.body).to include('The to-do has become uncompleted.')
    expect(response.body).to include('Uncompleted (1)')
  end

  it 'edits a completed to-do' do
    todo = create(:todo_item, :completed, user:)

    sign_in(user)

    get '/todos/completed'

    path_to_edit_todo = response.body.squish.match(%r{(/todos/edit/#{todo.id}\?previous=completed)})[1]

    get path_to_edit_todo

    expect(response).to render_template('todos/item/edit')
    expect(response.body).to include("action=\"/todos/#{todo.id}?previous=completed\"")

    put "/todos/#{todo.id}?previous=completed", params: {todo: {description: 'Buy tea'}}

    expect(response).to redirect_to('/todos/completed')

    follow_redirect!

    expect(response.body).to include('To-do successfully updated.')
    expect(response.body).to include('Completed (1)')
    expect(response.body).to include('Buy tea')
  end

  it 'edits an uncompleted to-do' do
    todo = create(:todo_item, user:)

    sign_in(user)

    path_to_edit_todo = response.body.squish.match(%r{(/todos/edit/#{todo.id}\?previous=uncompleted)})[1]

    get path_to_edit_todo

    expect(response).to render_template('todos/item/edit')
    expect(response.body).to include("action=\"/todos/#{todo.id}?previous=uncompleted\"")

    put "/todos/#{todo.id}?previous=uncompleted", params: {todo: {description: 'Buy milk'}}

    expect(response).to redirect_to('/todos/uncompleted')

    follow_redirect!

    expect(response.body).to include('To-do successfully updated.')
    expect(response.body).to include('Uncompleted (1)')
    expect(response.body).to include('Buy milk')
  end

  it 'deletes a completed to-do' do
    todo = create(:todo_item, :completed, user:)

    sign_in(user)

    get '/todos/completed'

    path_to_delete_todo = response.body.squish.match(%r{(/todos/#{todo.id}\?previous=completed)})[1]

    delete path_to_delete_todo

    expect(response).to redirect_to('/todos/completed')

    follow_redirect!

    expect(response.body).to include('To-do successfully deleted.')
    expect(response.body).to include('Completed (0)')
    expect(response.body).to include('Nothing done.')
  end

  it 'deletes an uncompleted to-do' do
    todo = create(:todo_item, user:)

    sign_in(user)

    path_to_delete_todo = response.body.squish.match(%r{(/todos/#{todo.id}\?previous=uncompleted)})[1]

    delete path_to_delete_todo

    expect(response).to redirect_to('/todos/uncompleted')

    follow_redirect!

    expect(response.body).to include('To-do successfully deleted.')
    expect(response.body).to include('Uncompleted (0)')
    expect(response.body).to include('Nothing to do.')
  end
end
