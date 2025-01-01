# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "px-4 py-16 md:py-32 text-center m-auto max-w-3xl" do
      h2 "Welcome to Chatbots AI", class: "text-base font-semibold leading-7 text-indigo-600 dark:text-indigo-500"
      para "Start creating your AI Chatbots now!", class: "mt-2 text-3xl sm:text-4xl font-bold text-gray-900 dark:text-gray-200"
      para class: "mt-6 text-xl leading-8 text-gray-700 dark:text-gray-400" do
        text_node "To add a new company, click on the "
        span "Companies", class: "font-semibold"
        text_node " link in the sidebar."
      end

      para class: "mt-6 text-xl leading-8 text-gray-700 dark:text-gray-400" do
        text_node "After creating a company, you can preview the chatbot creation process by clicking on the "
        span "Chatbot Creations", class: "font-semibold"
        text_node " link in the sidebar."
      end

      para class: "mt-6 text-xl leading-8 text-gray-700 dark:text-gray-400" do
        text_node "If the chatbot status is "
        span "ready,", class: "font-semibold"
        text_node "you can visit the chatbot by clicking on the "
        span "Visit Chatbot", class: "font-semibold"
        text_node " button in the Chatbot Creation details or in the Company details."
      end
    end
  end
end
