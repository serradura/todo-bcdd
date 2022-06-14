# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::V1::Todos::Item::CompleteController, type: :controller do
  before do
    warden = double

    allow(warden).to receive(:authenticate!)
    allow(warden).to receive(:user).with(:api_v1).and_return(user)

    allow(controller).to receive(:warden).and_return(warden)
  end

  describe '#update' do
    context 'when the todo is found' do
      let(:user) { create(:user) }
      let(:todo) { create(:todo_item, user:, created_at:, updated_at: created_at) }
      let(:created_at) { 10.seconds.ago }

      before { todo }

      it 'responds with 200' do
        expect { put :update, params: {id: todo.id} }
          .to change { todo.reload.completed_at }

        expect(response.status).to be == 200

        expect(json_response).to be == {}

        expect(todo.completed_at).to be > todo.created_at
      end
    end

    context "when a to-do isn't found" do
      let(:user) { User::Record.new(id: 1) }

      it 'responds with 404' do
        put :update, params: {id: 1}

        expect(response.status).to be == 404

        expect(json_response).to be == {}
      end
    end

    context 'when something went wrong' do
      let(:user) { User::Record.new(id: 1) }

      before do
        result = Micro::Case::Result::Failure.new(type: :invalid_attributes)

        allow(Todo::Item::Complete).to receive(:call).and_return(result)
      end

      it 'raises an error' do
        expect { put :update, params: {id: 1} }
          .to raise_error(NotImplementedError)

        expect(Todo::Item::Complete).to have_received(:call).with(->(input) {
          id = input[:scope].id
          owner_id = input[:scope].owner_id

          owner_id.value == user.id && id.value == 1
        })
      end
    end
  end
end
