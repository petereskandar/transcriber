import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AuthComponent } from './content/auth/auth.component';
import { UploadDocumentComponent } from './content/upload-document/upload-document.component';
import { ConfirmationComponent } from './content/confirmation/confirmation.component';
import { SignupComponent } from './content/signup/signup.component';
import { AuthGuard } from './services/guards/auth-guard.service';


const routes: Routes = [
  {path: '' , component: AuthComponent, pathMatch: 'full'},
  {path: 'signup' , component: SignupComponent, pathMatch: 'full'},
  {path: 'upload' , component: UploadDocumentComponent, pathMatch: 'full', canActivate: [AuthGuard]},
  {path: 'confirm', component: ConfirmationComponent, pathMatch: 'full', canActivate: [AuthGuard]}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
