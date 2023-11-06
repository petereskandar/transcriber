import { Component } from '@angular/core';
import { Router, RoutesRecognized } from '@angular/router';
import { filter, pairwise } from 'rxjs';
import { UserAuthService } from 'src/app/services/user-auth.service';

@Component({
  selector: 'app-confirmation',
  templateUrl: './confirmation.component.html',
  styleUrls: ['./confirmation.component.css']
})
export class ConfirmationComponent {

 constructor(private router: Router, 
            private userService: UserAuthService) {

  this.router.events
    .pipe(filter((evt: any) => evt instanceof RoutesRecognized), pairwise())
    .subscribe((events: RoutesRecognized[]) => {
      //this.previousUrl = events[0].urlAfterRedirects;
      console.log('previous url', events[0].urlAfterRedirects);
    });
   }

   ngOnInit() {}
}
