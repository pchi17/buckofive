class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    @contact.sender_email = current_user.email if logged_in?
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.valid?
      ContactMessageWorker.perform_async(@contact.sender_email, @contact.message)
      respond_to do |format|
        format.html do
          flash[:success] = 'message sent, one of our admins will get back to you asap'
          redirect_to contact_path
        end
        format.js
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js   { render :new }
      end
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:sender_email, :message)
    end
end
