require 'rails_helper'

feature 'the navigation bar header' do
  scenario 'user visits home page' do
    visit '/'
    save_and_open_page
    expect(page).to have_link('Buck O Five', href: '/')
    expect(page).to have_link('Home',    href: '/')
    expect(page).to have_link('About',   href: '/about')
    expect(page).to have_link('Help',    href: '/help')
    expect(page).to have_link('Contact', href: '/contact')
    # go to another page and the links should still be there
    click_link('Help')
    expect(page).to have_link('Buck O Five', href: '/')
    expect(page).to have_link('Home',    href: '/')
    expect(page).to have_link('About',   href: '/about')
    expect(page).to have_link('Help',    href: '/help')
    expect(page).to have_link('Contact', href: '/contact')
  end
end
