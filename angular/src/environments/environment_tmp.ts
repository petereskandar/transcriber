// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  REGION: 'eu-west-3',
  cognito: {
    userPoolId: 'eu-west-3_pNetY4Lfm',
    userPoolWebClientId: 'ii0ffm1og2d3qa7osvp8me9hn'
  },
  IDENTITY_POOL_ID: "eu-west-3:fd5f34c8-610d-4dee-89fb-f864398cd55e",
  ROLEARN: 'arn:aws:iam::250950161175:role/Cognito_demoIdPoolUnauth_Role',
  BUCKET: 'aws-devops-peter-eskandar',
  production: false
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.
