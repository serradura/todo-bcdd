# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::V1::Todos::ItemController, type: :controller do
  before do
    warden = double

    allow(warden).to receive(:authenticate!)
    allow(warden).to receive(:user).with(:api_v1).and_return(user)

    allow(controller).to receive(:warden).and_return(warden)
  end

  def uncompleted_item_as_json(todo)
    a_hash_including(
      'id'           => todo.id,
      'description'  => todo.description,
      'completed_at' => nil,
      'created_at'   => todo.created_at.iso8601(3),
      'updated_at'   => todo.updated_at.iso8601(3)
    )
  end

  describe '#index' do
    context 'when the status is invalid' do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 422' do
        get :index

        expect(response.status).to be == 422

        expect(json_response).to be == {'status' => 'is invalid'}
      end
    end

    context 'when the status is valid' do
      let(:user) { create(:user) }
      let(:todo) { create(:todo_item, user: user) }

      before { todo }

      it 'responds with 200' do
        get :index, params: {status: 'uncompleted'}

        expect(response.status).to be == 200

        expect(json_response.keys).to be == ['todos']

        expect(json_response['todos']).to match([
          uncompleted_item_as_json(todo)
        ])
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::List::FilterItems).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { get :index, params: {status: 'uncompleted'} }
          .to raise_error(NotImplementedError)

        expect(Todo::List::FilterItems)
          .to have_received(:call).with(->(input) { input[:scope].owner_id.value == user.id })
      end
    end
  end

  describe '#show' do
    context 'when a to-do is found' do
      let(:user) { create(:user) }
      let(:todo) { create(:todo_item, user: user) }

      it 'responds with 200' do
        get :show, params: {id: todo.id}

        expect(response.status).to be == 200

        expect(json_response).to match uncompleted_item_as_json(todo)
      end
    end

    context "when a to-do isn't found" do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 404' do
        get :show, params: {id: 1}

        expect(response.status).to be == 404

        expect(json_response).to be == {}
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::Item::Find).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { get :show, params: {id: 2} }
          .to raise_error(NotImplementedError)

        expect(Todo::Item::Find).to have_received(:call).with(->(input) {
          id = input[:scope].id
          owner_id = input[:scope].owner_id

          owner_id.value == user.id && id.value == 2
        })
      end
    end
  end

  describe '#create' do
    context 'when the todo params is valid' do
      let(:user) { create(:user) }

      it 'responds with 200' do
        description = Faker::Hipster.paragraph

        post :create, params: {todo: {description:}}

        expect(response.status).to be == 200

        todo = Todo::Item::Record.find(json_response['id'])

        expect(json_response).to match(uncompleted_item_as_json(todo))
      end
    end

    context 'when the todo params is invalid' do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 400' do
        nil_or_blank = [nil, {}].sample

        post :create, params: [nil_or_blank, {todo: nil_or_blank}].sample

        expect(response.status).to be == 400

        expect(json_response)
          .to match('error' => 'param is missing or the value is empty: todo')
      end
    end

    context 'when the description is invalid' do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 422' do
        post :create, params: {todo: {description: ''}}

        expect(response.status).to be == 422

        expect(json_response).to match('description' => "can't be blank")
      end
    end

    context "when the user was't found" do
      let(:user) { User::Record.new(id: 1) }

      it 'raises an error' do
        expect { post :create, params: {todo: {description: 'Test'}} }
          .to raise_error(NotImplementedError)
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::List::AddItem).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { post :create, params: {todo: {description: ''}} }
          .to raise_error(NotImplementedError)

        expect(Todo::List::AddItem)
          .to have_received(:call).with(->(input) { input[:scope].owner_id.value == user.id })
      end
    end
  end

  describe '#update' do
    context 'when the todo params is valid' do
      let(:user) { create(:user) }
      let(:todo) { create(:todo_item, user:) }

      before { todo }

      it 'responds with 200' do
        new_description = Faker::Hipster.paragraph

        params = {id: todo.id, todo: {description: new_description}}

        expect { put :update, params: }
          .to change { todo.reload.description }.to(new_description)

        expect(response.status).to be == 200

        expect(json_response).to be == {}
      end
    end

    context 'when the todo params is invalid' do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 400' do
        put :update, params: {id: 1, todo: [nil, {}].sample}

        expect(response.status).to be == 400

        expect(json_response)
          .to match('error' => 'param is missing or the value is empty: todo')
      end
    end

    context 'when the description is invalid' do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 422' do
        put :update, params: {id: 1, todo: {description: ''}}

        expect(response.status).to be == 422

        expect(json_response).to match('description' => "can't be blank")
      end
    end

    context "when a to-do isn't found" do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 404' do
        put :update, params: {id: 1, todo: {description: 'Test'}}

        expect(response.status).to be == 404

        expect(json_response).to be == {}
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::Item::UpdateDescription).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { put :update, params: {id: 1, todo: {description: 'Test'}} }
          .to raise_error(NotImplementedError)

        expect(Todo::Item::UpdateDescription).to have_received(:call).with(->(input) {
          id = input[:scope].id
          owner_id = input[:scope].owner_id

          owner_id.value == user.id && id.value == 1
        })
      end
    end
  end

  describe '#delete' do
    context 'when the todo is found' do
      let(:user) { create(:user) }
      let(:todo) { create(:todo_item, user:) }

      before { todo }

      it 'responds with 200' do
        expect { delete :delete, params: {id: todo.id} }
          .to change { Todo::Item::Record.where(id: todo.id).count }
          .from(1)
          .to(0)

        expect(response.status).to be == 200

        expect(json_response).to be == {}
      end
    end

    context "when a to-do isn't found" do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 404' do
        delete :delete, params: {id: 1}

        expect(response.status).to be == 404

        expect(json_response).to be == {}
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::Item::Delete).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { delete :delete, params: {id: 1} }
          .to raise_error(NotImplementedError)

        expect(Todo::Item::Delete).to have_received(:call).with(->(input) {
          id = input[:scope].id
          owner_id = input[:scope].owner_id

          owner_id.value == user.id && id.value == 1
        })
      end
    end
  end
end
