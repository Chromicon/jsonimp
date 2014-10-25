=head1 VERSION

Version 0.01

=head1 SYNOPSIS

HYSCRIPT to import JSON from a hydll webservices
  
     
=head1 Usage

Specify the function as you would a perl JSONCall. 
See the Hydstra helpfile: HYDLLP - Flat DLL Interface to Hydstra

=head1 Example

  { 
  'function'=> 'get_ts_traces', 
    'version'=> 2,
    'params'=> {
      'site_list'=> '142714', 
      'datasource'=> 'A', 
      'varfrom'=> '100.09', 
      'varto'=> '100.09', 
      'start_time'=> '20140701000000', 
      'end_time'=>'20140802000000', 
      'data_type'=> 'mean', 
      'interval'=> 'day', 
      'multiplier'=> '1'
    }
  }

