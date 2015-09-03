require 'rails_helper'

feature 'static pages' do
  def self.check_title(page_name)
    scenario 'has the correct title' do
      expect(page).to have_title(page_title(page_name))
    end
  end

  def self.check_logo
    scenario 'has a site logo' do
      expect(page).to have_css('#logo', text: 'Buck O Five')
    end
  end

  def self.check_links
    scenario 'has 2 links to root_path' do
      expect(page).to have_link('Buck O Five', href: '/')
      expect(page).to have_link('Home', href: '/')
    end

    scenario 'has 1 link for help, about, and contact' do
      expect(page).to have_link('About',   href: '/about')
      expect(page).to have_link('Help',    href: '/help')
      expect(page).to have_link('Contact', href: '/contact')
    end
  end

  feature 'Home Page' do
    before(:each) { visit '/' }

    check_title('Home')
    check_logo
    check_links
  end

  feature 'About Page' do
    before(:each) { visit '/about' }

    check_title('About')
    check_logo
    check_links
  end

  feature 'Help Page' do
    before(:each) { visit '/help' }

    check_title('Help')
    check_logo
    check_links
  end

  feature 'Contact Page' do
    before(:each) { visit '/contact' }

    check_title('Contact')
    check_logo
    check_links
  end
end
