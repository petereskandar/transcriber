import { MatStepperModule } from '@angular/material/stepper';
import { MatBottomSheetModule } from '@angular/material/bottom-sheet';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import { NgModule } from '@angular/core';
import { NgxSpinnerModule } from 'ngx-spinner';

@NgModule({
  declarations: [],
  imports: [
    MatStepperModule,
    MatBottomSheetModule,
    MatToolbarModule,
    MatIconModule,
    MatProgressSpinnerModule,
    NgxSpinnerModule
  ],
  exports: [
    MatStepperModule,
    MatBottomSheetModule,
    MatToolbarModule,
    MatIconModule,
    MatProgressSpinnerModule,
    NgxSpinnerModule
  ]
})
export class MaterialModule { }
