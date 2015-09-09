module OmniAuthMock
  def mock_auth_hash
    attrs = attributes_for(:authentication)

    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      'provider' => attrs[:provider],
      'uid'      => attrs[:uid],
      'credentials' => {
        'token'  => attrs[:token],
        'secret' => attrs[:secret]
      },
      'info' => {
        'nickname' => 'super philip',
        'image'    => 'http://twitter.com/mypic'
      }
    })
  end
end
