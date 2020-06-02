class LokaliseJob < ApplicationJob
  queue_as :default

  def perform(tool_id)
    tool = Tool.find(tool_id)
    return unless tool

    tool.update_translation
  end
end
