ActiveAdmin.register Company do
  config.sort_order = "url_asc"

  # Specify parameters which should be permitted for assignment
  permit_params :name, :url, :is_manual

  # or consider:
  #
  # permit_params do
  #   permitted = [:name, :url]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  before_save do |company|
    company.url = Chatbots::DomainParser.call(company.url) if company.url.present?
  end

  after_create do |company|
    chatbot_creation = company.chatbot_creations.build
    chatbot_creation.is_manual = params.dig(:company, :is_manual)
    chatbot_creation.save!

    ChatbotCreationPipelineJob.perform_later(company_id: company.id, chatbot_creation_id: chatbot_creation.id)
  end

  action_item :visit_chatbot, only: %i[show], priority: 0 do
    link_to "Visit Company", root_path(url: resource.url), target: "_blank", class: "action-item-button"
  end

  # Add or remove filters to toggle their visibility
  filter :id
  filter :name
  filter :url
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    column :url
    column :created_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :name
      row :url
      row :created_at
      row :updated_at
    end

    panel "Chatbot Creations" do
      table_for resource.chatbot_creations do
        column :id
        column :status
        column :scraped_content do |chatbot_creation|
          chatbot_creation.scraped_content.truncate(50) if chatbot_creation.scraped_content
        end
        column :created_at
        column :actions do |chatbot_creation|
          link_to "Show", admin_chatbot_creation_path(chatbot_creation)
        end
      end
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
      f.input :url
      f.input :is_manual, as: :boolean, label: "Manual Pipeline", hint: "Skips scraping and you have to provide training data and trigger the pipeline manually. With this option enabled in the chatbot creation, when new scraped content is provided, the pipeline retrigger will train AI model with the new data."
    end
    f.actions
  end
end
