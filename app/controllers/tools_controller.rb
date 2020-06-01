class ToolsController < ApplicationController
  before_action :set_tool, only: %i[show edit update destroy update_translation]

  def index
    @tools = Tool.all
  end

  def show; end

  def new
    @tool = Tool.new
  end

  def create
    @tool = Tool.new(tool_params)

    respond_to do |format|
      if @tool.save
        format.html do
          redirect_to @tool, notice: 'Tool created successfully'
        end
      else
        format.html { render :new }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @tool.update(tool_params)
        format.html do
          redirect_to @tool,
                      notice: 'Tool was successfully updated.'
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @tool.destroy

    redirect_to tools_path
  end

  def update_translation; end

  private

  def tool_params
    params.require(:tool).permit(:name, :language, :json_spec)
  end

  def set_tool
    @tool = Tool.find(params[:id])
  end
end
