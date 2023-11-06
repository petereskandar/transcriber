import { UserAuthService } from './../user-auth.service';
import { inject } from '@angular/core';
import { Router, CanActivateFn, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';

export const AuthGuard: CanActivateFn = (
  route: ActivatedRouteSnapshot,
  state: RouterStateSnapshot
): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree => {

  const router: Router = inject(Router);
  const auth: UserAuthService = inject(UserAuthService);
  return new Promise((resolve) => {
    auth.checkUserSession()
      .then((userSession) => {
        console.log('Auth Guard', userSession)
        auth.setLoggedUser(userSession);
        resolve(true);
      })
      .catch(err => {
        console.log('Auth Guard ---> User not Authenticated')
        router.navigate(['/']);
        resolve(false);
      });
  })
}
