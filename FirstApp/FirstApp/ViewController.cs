using System;
using UIKit;
using Firebase.Auth;

    namespace FirstApp
    {
        
        public partial class ViewController : UIViewController
        {


            protected ViewController(IntPtr handle) : base(handle)
            {
                // Note: this .ctor should not contain any initialization logic.
            }

            public override void ViewDidLoad()
            {
                base.ViewDidLoad();
                // Perform any additional setup after loading the view, typically from a nib.

            }

            public override void DidReceiveMemoryWarning()
            {
                base.DidReceiveMemoryWarning();
                // Release any cached data, images, etc that aren't in use.
            }


            partial void LoginBtn_TouchUpInside(UIButton sender)
            {


            string email = nameTxtField.Text;
            string password = passTxtField.Text;

            if (email == "" || password == "")
            {
                UIAlertView alert = new UIAlertView()
                {
                    Title = "Error",
                    Message = "Please enter name and/or password!"
                };
                alert.AddButton("OK");
                alert.Show();

            }else{
                    Auth.DefaultInstance.SignIn(email, password, (user, error) =>
                     {
                         if (error != null)
                         {
                             AuthErrorCode errorCode;
                             if (IntPtr.Size == 8) // 64 bits devices
                                errorCode = (AuthErrorCode)((long)error.Code);
                             else // 32 bits devices
                                errorCode = (AuthErrorCode)((int)error.Code);

                            // Posible error codes that SignIn method with email and password could throw
                            // Visit https://firebase.google.com/docs/auth/ios/errors for more information
                            switch (errorCode)
                             {
                                 case AuthErrorCode.OperationNotAllowed:
                                 case AuthErrorCode.InvalidEmail:
                                 case AuthErrorCode.UserDisabled:
                                 case AuthErrorCode.WrongPassword:
                                 default:
                                     // Print error
                                     Console.WriteLine(error);
                                    break;
                             }
                         }
                         else
                         {
							 // Do your magic to handle authentication result
							 UIAlertView alert = new UIAlertView()
							 {
								 Title = "Success",
								 Message = "Login successfull"
							 };
							 alert.AddButton("OK");
							 alert.Show();
                        }
                     });
                }


            }
        }

    }
