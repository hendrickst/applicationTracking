xquery version "3.1";

module namespace tsh="tsh";

declare variable $tsh:adminUser := 'admin';
declare variable $tsh:adminPassword :='***REMOVED***';

declare variable $tsh:appLocal := '/db/apps/jobs/';
declare variable $tsh:base := '/db/jobs/';
declare variable $tsh:working := $tsh:base || "/applications/";
declare variable $tsh:appBase :='/db/apps/jobs/';
declare variable $tsh:XMLPath := $tsh:appBase || 'resources/xml/';
