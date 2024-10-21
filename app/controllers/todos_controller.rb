# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :authenticate_user

  # TODO: potentially remove/refactor these before_actions and move the business logic into the specific methods (i.e.: show and use the todo id)
  before_action :set_todo_lists
  before_action :set_todos
  before_action :set_todo, except: [:index, :create]

  rescue_from ActiveRecord::RecordNotFound do |not_found|
    key = not_found.model == 'TodoList' ? :todo_list : :todo

    render_json(404, key => { id: not_found.id, message: 'not found' })
  end

  def index
    todos = @todos.filter_by_status(params).order_by(params).map(&:serialize_as_json)

    render_json(200, todos:)
  end

  def create

    # TODO: check any validation before creating the todo
    todo = @todos.create(todo_params.except(:completed))

    if todo.valid?
      render_json(201, todo: todo.serialize_as_json)
    else
      render_json(422, todo: todo.errors.as_json)
    end
  end

  def show
    render_json(200, todo: @todo.serialize_as_json)
  end

  def destroy
    @todo.destroy

    render_json(200, todo: @todo.serialize_as_json)
  end

  def update
    @todo.update(todo_params)

    if @todo.valid?
      render_json(200, todo: @todo.serialize_as_json)
    else
      render_json(422, todo: @todo.errors.as_json)
    end
  end

  def complete
    @todo.complete!

    render_json(200, todo: @todo.serialize_as_json)
  end

  def incomplete
    @todo.incomplete!

    render_json(200, todo: @todo.serialize_as_json)
  end

  private

    def todo_lists_only_non_default? = false

    def set_todos
      scope =
        if params[:todo_list_id].present?
          @todo_lists.find(params[:todo_list_id])
        else
          action_name == 'create' ? @todo_lists.default.first! : current_user
        end

      @todos = scope.todos
    end

    def set_todo
      @todo = @todos.find(params[:id])
    end

    def todo_params
      params.require(:todo).permit(:title, :due_at, :completed)
    end
end
