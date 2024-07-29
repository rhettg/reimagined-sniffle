# frozen_string_literal: true

class Image < ContentItem
  def as_json(options = {})
    super(options.merge(methods: :type)).merge(file_url: file_url)
  end

  def file_url
    if file.attached?
      Rails.application.routes.url_helpers.rails_blob_path(file, only_path: false, host: default_url_options[:host])
    else
      Rails.logger.debug "File is not attached"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error generating file URL: #{e.message}"
    nil
  end

  private

  def default_url_options
    { host: Rails.application.config.action_mailer.default_url_options&.fetch(:host, 'localhost:3000') }
  end
end
