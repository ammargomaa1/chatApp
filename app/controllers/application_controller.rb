# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  # Index action
  def index
    # Set the number of items per page (default: 25)
    @applications = Application.select(:name, :token).page(params[:page]).per(params[:per_page] || 25)

    applications_data = @applications.map do |app|
      { name: app.name, token: app.token }
    end

    render json: {
      current_page: @applications.current_page,
      total_pages: @applications.total_pages,
      total_count: @applications.total_count,
      applications: applications_data
    }
  end

  # Create action
  def create
    # Get the name from the request parameters
    name = params[:name]
    token = ""
    # Loop to generate a unique token
    begin
      loop do
        token = SecureRandom.hex(16)
        break unless Application.exists?(token: token)
      end
    rescue StandardError => e
      # Handle errors (optional)
      return
    end

    # Create the application record (now token is defined)
    application = Application.create(name: name, token: token)

    # Render a success response or redirect to a relevant page
    render json: { name: application.name, token: application.token }, status: :created
  end
end
