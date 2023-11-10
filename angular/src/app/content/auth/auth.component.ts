import { Router } from '@angular/router';
import { IUser, UserAuthService } from './../../services/user-auth.service';
import { Component, NgZone, OnInit } from '@angular/core';

@Component({
  selector: 'app-auth',
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.css']
})
export class AuthComponent implements OnInit {

  loading: boolean;
  signInError: boolean = false;
  user: IUser;

  constructor(private userService: UserAuthService,
    private router: Router,
    private ngZone: NgZone) {
    this.loading = false;
    this.user = {} as IUser;
  }

  ngOnInit() {
    this.userService.checkUserSession()
      .then(userSession => {
        if (userSession) {
          console.log('Current User Session', userSession);
          this.userService.setLoggedUser(userSession);
          this.router.navigate(['./upload'], { queryParams: { index: 1 } });
        }
      });
  }

  ngOnDestroy() {}

  // SignIn Action
  public signIn(): void {
    this.loading = true;
    this.signInError = false;
    // Sign In
    this.userService.signIn(this.user)
      .then((cognitoUser) => {
        this.router.navigate(['/upload']);
      }).catch((error) => {
        this.signInError = true;
        this.loading = false;
      });
  }

}
