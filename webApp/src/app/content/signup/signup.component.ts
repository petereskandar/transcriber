import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { IUser, UserAuthService } from 'src/app/services/user-auth.service';

@Component({
  selector: 'app-signup',
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css']
})
export class SignupComponent {

  loading: boolean;
  isConfirm: boolean;
  errMsg: String;
  user: IUser;

  constructor(private router: Router,
              private userService: UserAuthService) {
    this.loading = false;
    this.isConfirm = false;
    this.errMsg = '';
    this.user = {} as IUser;
  }

  public signUp(): void {
    this.loading = true;
    this.userService.signUp(this.user)
    .then(() => {
      this.loading = false;
      this.isConfirm = true;
    }).catch((err) => {
      this.errMsg = err;
      this.loading = false;
    });
  }

  public confirmSignUp(): void {
    this.loading = true;
    this.userService.confirmSignUp(this.user)
    .then(() => {
      this.router.navigate(['/']);
    }).catch(() => {
      this.loading = false;
    });
  }


}
