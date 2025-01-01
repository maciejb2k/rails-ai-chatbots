ActiveAdmin.register ChatbotCreation do
  config.sort_order = "created_at_desc"

  # Specify parameters which should be permitted for assignment
  permit_params :chatflow_id, :document_store_id, :status, :scraped_content, :process_errors, :company_id, :screenshots, :is_manual

  # or consider:
  #
  # permit_params do
  #   permitted = [:chatflow_id, :document_store_id, :status, :scraped_content, :process_errors, :company_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :index, :show, :update, :edit

  action_item :visit_chatbot, only: %i[show], priority: 0 do
    link_to "Visit Chatbot", root_path(url: resource.company.url), target: "_blank", class: "action-item-button"
  end

  action_item :retry, only: %i[show], priority: 1 do
    link_to "Trigger Chatbot Creation", retry_admin_chatbot_creation_path(resource), method: :post, class: "action-item-button"
  end

  member_action :retry, method: :post do
    resource.update!(status: :pending, process_errors: [])

    ChatbotCreationPipelineJob.perform_later(
      company_id: resource.company_id,
      chatbot_creation_id: resource.id
    )

    redirect_to root_path(url: resource.company.url)
  end

  # Add or remove filters to toggle their visibility
  filter :id
  filter :chatflow_id
  filter :document_store_id
  filter :status
  filter :scraped_content
  filter :process_errors
  filter :company
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    column :company
    column :status
    column :is_manual
    column :scraped_content do |chatbot_creation|
      chatbot_creation.scraped_content.truncate(50) if chatbot_creation.scraped_content
    end
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :is_manual
      row :id
      row :chatflow_id
      row :document_store_id
      row :status
      row :process_errors do |chatbot_creation|
        begin
          pre JSON.pretty_generate(chatbot_creation.process_errors)
        rescue JSON::ParserError => e
          chatbot_creation.process_errors
        end
      end
      row :company
      row :created_at
      row :updated_at
      row :scraped_content
      row :screenshot do
        if resource.screenshot.attached?
          image_tag url_for(resource.screenshot)
        else
          "No screenshot attached"
        end
      end
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :chatflow_id
      f.input :document_store_id
      f.input :status
      f.input :scraped_content
      f.input :company
      f.input :screenshot, as: :file
      f.input :is_manual, hint: "With this enabled, the chatbot creation will skip the scraping step, and will enable changing AI models based on the newly provided scraped content on every retry (clicking Re-Trigger Chatbot Creation)."
    end
    f.actions
  end
end
