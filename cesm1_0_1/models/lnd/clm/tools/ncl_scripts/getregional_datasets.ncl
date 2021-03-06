;
; Extract out regional datasets needed to run clm from the global datasets.
; NOTE: Requires at least NCL version 5.1.0 or later...
;
;  Erik Kluzek
;  Aug/28/2009
;  $Id: getregional_datasets.ncl 24409 2010-08-16 19:27:11Z erik $
;  $HeadURL;
;
begin
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl";
  ; ===========================================================================================================
  ;
  ; IMPORTANT NOTE: EDIT THE FOLLOWING TO CUSTOMIZE or use ENV VARIABLE SETTINGS
  ; Edit the following as needed to interpolate to a new resolution.
  ;
  ; Input resolution and position
  ;
  latS       = stringtodouble( getenv("S_LAT") );   ; Get south latitude from env variable
  latN       = stringtodouble( getenv("N_LAT") );   ; Get north latitude from env variable
  lonE       = stringtodouble( getenv("E_LON") );   ; Get east longitude from env variable
  lonW       = stringtodouble( getenv("W_LON") );   ; Get west longitude from env variable
  id         = getenv("ID");                        ; Get mydataid from env variable
  res        = getenv("RES");                       ; Get resolution from env variable
  rcp        = getenv("RCP");                       ; Get representative concentration pathway from env variable
  lmask      = getenv("MASK");                      ; Get input land/use mask to use from env variable
  sim_year   = stringtointeger( getenv("SIM_YR") ); ; Get input simulation year to use from env variable
  sim_yr_rng = getenv("SIM_YR_RNG");                ; Get input simulation year range to use
  debug_str  = getenv("DEBUG");                     ; Don't run just -- debug
  print_str  = getenv("PRINT");                     ; Do Extra printing for debugging
  csmdata    = getenv("MYCSMDATA");                 ; Your personal CCSM inputdata location

  if ( ismissing(res) )then
     res = "1.9x2.5";
  end if
  if ( ismissing(rcp) )then
     rcp = "-999.9";
  end if
  if ( ismissing(lmask) )then
     lmask = "gx1v6";
  end if
  if ( ismissing(latS) )then
     latS = 52.0d00;
  end if
  if ( ismissing(latN) )then
     latN = 73.0d00;
  end if
  if ( ismissing(lonW) )then
     lonW = 190.0d00;
  end if
  if ( ismissing(lonE) )then
     lonE = 220.0d00;
  end if
  if ( ismissing(sim_year) )then
     sim_year = 2000;
  end if
  if ( ismissing(sim_yr_rng) )then
     sim_yr_rng = "constant";
  end if
  if ( ismissing(print_str) )then
     printn = False;
  else
     if ( print_str .eq. "TRUE" )then
        printn = True;
     else
        printn = False;
     end if
  end if
  if ( ismissing(debug_str) )then
     debug = False;
  else
     if ( debug_str .eq. "TRUE" )then
        print( "DEBUG is TRUE do extra printing AND do NOT execute -- just print what WOULD happen" );
        debug  = True;
        printn = True;
     else
        debug = False;
     end if
  end if
  if ( ismissing(id) )then
     id = "13x12pt_f19_alaskaUSA";
  end if
  if ( ismissing(csmdata) )then
     csmdata    = getenv("CSMDATA");   ; Standard CCSM inputdata location
     if ( ismissing(csmdata) )then
        csmdata = "/fs/cgd/csm/inputdata";
     end if
  end if
  print( "Extract out regional datasets from global datasets" );
  if ( printn .eq. True )then
    print( "Global:   Resolution="+res+" mask="+lmask+" simyear="+sim_year );
    if ( sim_yr_rng .ne. "constant" )then
       print( "          sim_year_range="+sim_yr_rng+" rcp="+rcp );
    end if
    print( "Regional: id="+id+" Latitude="+latS+"-"+latN+" Longitude="+lonW+"-"+lonE );
  end if

  ;
  ; Setup the namelist query script
  ;
  ldate     = systemfunc( "date" );
  clmroot  = getenv("CLM_ROOT");
  querynml = "bld/queryDefaultNamelist.pl -silent -justvalue ";
  queryopts= " -options bgc=cn,mask="+lmask+",rcp="+rcp;
  querynyr = ",sim_year="+sim_year+",sim_year_range="+sim_yr_rng;      ; Query for standard file years
  if ( sim_yr_rng .eq. "constant" )then
     queryyrs = ",sim_year=1850,sim_year_range=1850-2000";             ; Query for files that are always transient
  else
     queryyrs = querynyr;
  end if
  if ( .not. ismissing(csmdata) )then
     querynml = querynml+" -csmdata "+csmdata;
  end if
  if ( ismissing(clmroot) )then
     querynml = "../../"+querynml;
  else
     querynml = clmroot+"/models/lnd/clm/"+querynml;
  end if
  gridfile  = systemfunc( querynml+queryopts+querynyr+" -res "+res+" -var fatmgrid" );
  ;
  ; Open file
  ;
  if ( systemfunc("test -f "+gridfile+"; echo $?" ) .ne. 0 )then
     print( "Input gridfile does not exist or not found: "+gridfile );
     exit
  end if
  if ( printn .eq. True )then
     print( "gridfile:"+gridfile );
  end if
  ncg     = addfile( gridfile,  "r" );

  if ( debug .eq. True )then
    print( "Env:      mycsmdata="+csmdata+" query="+querynml+queryopts+querynyr );
  end if
  indx = region_ind ( (/ncg->LATIXY/), (/ncg->LONGXY/), latS, latN, lonW, lonE );

  if ( debug .eq. True )then
     print( "Indices:"+indx );
  end if
  if ( printn .eq. True )then
     latdim = indx(1) - indx(0) + 1;
     londim = indx(3) - indx(2) + 1;
     print( "Grid size:"+latdim+"x"+londim );
     print( "Actual grid span: Latitude="+ncg->LATIXY(indx(2),indx(0))+"-"+ncg->LATIXY(indx(3),indx(1))+" Longitude="+ncg->LONGXY(indx(2),indx(0))+"-"+ncg->LONGXY(indx(3),indx(1)) );
  end if
  ;
  ; Setup filenames to process
  ;

  files     = (/ "fatmgrid", "fatmlndfrc", "fsurdat", "fpftdyn", "flndtopo", "faerdep", "stream_fldfilename_ndep", "domainfile" /)
  qryopt    = (/ querynyr,   querynyr,     querynyr,  querynyr,  querynyr,   queryyrs,  queryyrs,                  querynyr     /)
  filelatnm = (/ "lsmlat",   "lsmlat",     "lsmlat",  "lsmlat",  "lsmlat",   "lat",     "lat",                     "nj"         /)
  filelonnm = (/ "lsmlon",   "lsmlon",     "lsmlon",  "lsmlon",  "lsmlon",   "lon",     "lon",                     "ni"         /)

  ;
  ; Loop over each of the files to process...
  ;
  do i = 0, dimsizes(files)-1
     ;
     ; Get the filename of the input global file and the output regional filename
     ;
     if ( files(i) .eq. "domainfile" ) then
        queryopt= " -namelist shr_strdata_nml";
     else
        if ( files(i) .eq. "stream_fldfilename_ndep" ) then
           queryopt= " -namelist ndepdyn_nml";
        else
           queryopt= " ";
        end if
     end if
     qry = querynml+queryopts+qryopt(i)+queryopt+" -res "+res+" -var "+files(i);
     globalfile = systemfunc( qry );
     if ( systemfunc("test -f "+globalfile+"; echo $?" ) .ne. 0 )then
        print( "Input global "+files(i)+" file does not exist or not found: "+globalfile );
        if ( printn .eq. True )then
           print( "qry was"+qry );
        end if
        continue;
     end if
     if ( debug .eq. True )then
        print( "Process file: "+globalfile );
     end if
     qry     = querynml+queryopts+qryopt(i)+queryopt+" -usrname "+id+" -var "+files(i);
     regfile = systemfunc( qry );
     if ( ismissing(regfile) )then
        print( "Output regional filename was NOT found: "+regfile );
        if ( printn .eq. True )then
           print( "qry was"+qry );
        end if
        continue;
     end if
     ;
     ; Run ncks on it over the region of interest
     ;
     cmd = "ncks -O -d "+filelatnm(i)+","+indx(0)+","+indx(1)+" -d "+filelonnm(i)+","+indx(2)+","+indx(3);
     cmd = cmd + " " + globalfile + " "+regfile;
     print( "Execute:"+cmd );
     if ( debug .eq. False )then
        if (  systemfunc( cmd+"; echo $?" ) .ne. 0 )then
           print( "Command did not complete successfully: " );
           exit
        end if
        ;
        ; Open up resultant file for writing
        ;
        nco = addfile( regfile, "w" );
        nco@history = nco@history + ":"+ldate + ": ";
        ;
        ; Add in coordinate variables for latitude/longitude
        ;
        var = filelatnm(i);
        if ( .not. isfilevar( nco, var ) .and. var .ne. "nj" )then
           if ( printn .eq. True )then
              print( "add "+var );
           end if
           nco@history = nco@history + " add "+var;
           nco->$var$  = (/ nco->LATIXY(:,0) /);
        end if
        var = filelonnm(i);
        if ( .not. isfilevar( nco, var ) .and. var .ne. "ni" )then
           if ( printn .eq. True )then
              print( "add "+var );
           end if
           nco@history = nco@history + " add "+var;
           nco->$var$  = (/ nco->LONGXY(0,:) /);
        end if
        ;
        ; Now check that internal variables are consistent
        ;
        var = "NUMLON";
        if( isfilevar( nco, var ) )then
           if ( printn .eq. True )then
              print( "modify "+var );
           end if
           nco@history = nco@history + " modify "+var;
           nco->$var$(:) = dimsizes( nco->LATIXY(0,:) );
        end if
        var = "EDGEN";
        if( isfilevar( nco, var ) )then
           if ( printn .eq. True )then
              print( "modify "+var );
           end if
           nco@history = nco@history + " modify "+var;
           nco->$var$ = max( nco->LATN );
        end if
        var = "EDGES";
        if( isfilevar( nco, var ) )then
           if ( printn .eq. True )then
              print( "modify "+var );
           end if
           nco@history = nco@history + " modify "+var;
           nco->$var$ = min( nco->LATS );
        end if
        var = "EDGEE";
        if( isfilevar( nco, var ) )then
           if ( printn .eq. True )then
              print( "modify "+var );
           end if
           nco@history = nco@history + " modify "+var;
           nco->$var$ = max( nco->LONE );
        end if
        var = "EDGEW";
        if( isfilevar( nco, var ) )then
           if ( printn .eq. True )then
              print( "modify "+var );
           end if
           nco@history = nco@history + " modify "+var;
           nco->$var$ = min( nco->LONW );
        end if
     end if
  end do

  print( "================================================================================================" );
  print( "Successfully extracted regional datasets from global datasets" );

end
