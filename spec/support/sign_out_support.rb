module SignOutSupport
  def sign_out(_user)
    visit root_path
    find('.dropdown').click
    click_on 'ログアウト'
  end
end
