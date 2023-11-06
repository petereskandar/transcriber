import { FormControl } from '@angular/forms';

export function requiredFileType( ...types: string[] ) {
  return function ( control: FormControl ) {
    const file = control.value;
    if ( file ) {
      const extension = file.name.split('.')[1].toLowerCase();
      if ( types.indexOf(extension) === -1 ) {
        return {
          requiredFileType: true
        };
      }

      return null;
    }

    return null;
  };
}

export function fileSizeValidator() {
  return function(control: FormControl) {
    const file: File = control.value;
    if (file) {
     // const path = file.name.replace(/^.*[\\\/]/, "");
      const fileSize = file.size;
      const fileSizeInKB = fileSize / (1024*1024);
      if (fileSizeInKB >= 10) {
        return {
          fileSizeValidator: true
        };
      } else {
        return null;
      }
    }
    return null;
  };
}


/*export function uploadProgress<T>( cb: ( progress: number ) => void ) {
  return tap(( event: HttpEvent<T> ) => {
    if ( event.type === HttpEventType.UploadProgress ) {
      console.log('progess', Math.round((100 * event.loaded) / event.total))
      cb(Math.round((100 * event.loaded) / event.total));
    }
  });
}*/
