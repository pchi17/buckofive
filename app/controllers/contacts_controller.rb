class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    @contact.sender_email = current_user.email if logged_in?
  end

  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      format.html do
        if @contact.valid?
          AdminMailer.send_contact_message(@contact.sender_email, @contact.message)
          flash[:success] = 'message sent'
          redirect_to contact_path
        else
          render :new
        end
      end
      format.js do
        if @contact.valid?
          AdminMailer.send_contact_message(@contact.sender_email, @contact.message)
          @contact = Contact.new
        else
          render :new
        end
      end
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:sender_email, :message)
    end
end
