module UserHelper
  def signup_codes_exist?
    SignupCode.codes_exist?
  end
end
