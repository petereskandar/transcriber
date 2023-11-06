import { environment } from './../../environments/environment';
import { Injectable } from '@angular/core';
import { Amplify, Auth } from 'aws-amplify';
import * as AWS from 'aws-sdk';
import { BehaviorSubject } from 'rxjs';


export interface IUser {
  email: string;
  password: string;
  showPassword: boolean;
  code: string;
  name: string;
}


@Injectable({
  providedIn: 'root'
})
export class UserAuthService {

  user: any | undefined;
  private authenticationSubject!: BehaviorSubject<any>;

  constructor() {
    Amplify.configure({
      Auth: environment.cognito
    });
    this.authenticationSubject = new BehaviorSubject<boolean>(false);
  }

  // Sign In 
  public signIn(user: IUser): Promise<any> {
    return Auth.signIn(user.email, user.password)
  }

  // Sign Out
  signOut() {
    return new Promise((resolve, reject) => {
      Auth.signOut().then((res) => {
        this.setLoggedUser(null);
        resolve(res);
      }).catch((err) => reject(err));
    })

  }

  signUp(user: IUser): Promise<any> {
    return Auth.signUp({
      username: user.email,
      password: user.password,
    });
  }

  confirmSignUp(user: IUser): Promise<any> {
    return Auth.confirmSignUp(user.email, user.code);
  }

  // set AWS Security & Access tokens
  setAWSCredentials(cognitoUser: any | undefined) {
    AWS.config.region = environment.REGION;
    if (cognitoUser != null) {
      cognitoUser.getSession((_err: any, result) => {
        if (result) {
          AWS.config.credentials = new AWS.CognitoIdentityCredentials({
            IdentityPoolId: environment.IDENTITY_POOL_ID, //'eu-west-3:fd5f34c8-610d-4dee-89fb-f864398cd55e',
            Logins: {
              ['cognito-idp.'+ environment.REGION +'.amazonaws.com/'+ environment.cognito.userPoolId +'']: result.getIdToken().getJwtToken()
            }
          });
        }
      });
    }
  }

  // get Current Logged User Attributes
  public getCurrentUserInfo(): Promise<any> {
    return Auth.currentUserInfo();
  }

  // save logged user data
  setLoggedUser(cognitoUser: any | undefined) {
    this.user = cognitoUser;
    this.setAWSCredentials(cognitoUser);
  }

  // get current logged user data
  get loggedUser() {
    return this.user || null;
  }

  // Check Current User Session
  checkUserSession() {
    return Auth.currentAuthenticatedUser();
  }

  // check User Credentials
  checkUserCredentials() {
    return Auth.currentUserCredentials();
  }

}
