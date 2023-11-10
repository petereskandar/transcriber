import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { UserAuthService } from './services/user-auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'audio-transcriber';

  constructor(public userService: UserAuthService,
    private router: Router) {}
    
  signOut() {
    this.userService.signOut().then(res => {
      this.router.navigate(['/']);
    })
  }
}
