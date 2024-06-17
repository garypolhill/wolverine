#!/usr/bin/perl
#
# build-iv-expt.pl
#
# Script to build intervention files and accompanying parameter sensitivity
# experiments for work with Wolverine.

use strict;
use File::Spec;

# Defaults

my $iv2_start = 2016;
my $iv2_stop = 2022;
my @iv2_rent_options = (1.05, 1.2, 1.5);
my @iv2_bldg_years = (1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010);
my @districts = ('Akalla', 'Husby', 'Kista', 'Rinkeby', 'Tensta');
my $out_stem = "iv-jarva";
my $n_sample = 100;
my $sim_start = 2005;
my $sim_stop = 2025;
my $nlogo_py = "\$HOME/git/NetLogo-tk/nlogo.py";
my $concur = 10;
my $project = "sm7";
my $gigaram = 16;
my $version = "6.3.0";

my %paper_parameters = (
  'scb-year' => 1,
  'n-activities' => 1,
  'n-services' => 1,
  'dwellings-per-tower-block' => 1,
  'dwellings-per-terrace' => 1,
  'apartments-in-houses?' => 1,
  'rent-per-m2' => 1,
  'en-eff-decay' => 1,
  'en-eff-dk-p-yr' => 1,
  'start-year' => 1,
  'n-households' => 1,
  'only-rented?' => 1,
  'max-floor-space-diff' => 1,
  'override-eth?' => 1,
  'p-eth-1' => 1,
  'n-ethnicities' => 1,
  'eth-1-work-reach' => 1,
  'eth-ge2-work-reach' => 1,
  'eth-1-min-reach' => 1,
  'eth-1-max-reach' => 1,
  'eth-ge2-min-reach' => 1,
  'eth-ge2-max-reach' => 1,
  'eth-1-min-trust' => 1,
  'eth-1-max-trust' => 1,
  'eth-ge2-min-trust' => 1,
  'eth-ge2-max-trust' => 1,
  'range-crime' => 1,
  'range-money' => 1,
  'range-hetero' => 1,
  'range-racism' => 1,
  'trust-diff' => 1,
  'income-sd' => 1,
  'HBS-year' => 1,
  'xp-food?' => 1,
  'xp-clothes?' => 1,
  'xp-leisure?' => 1,
  'xp-health?' => 1,
  'xp-comms?' => 1,
  'xp-home?' => 1,
  'xp-childcare?' => 1,
  'xp-goods?' => 1,
  'xp-transport?' => 1,
  'xp-narcotics?' => 1,
  'max-cycle-dist' => 1,
  'max-walk-dist' => 1,
  'p-cycle' => 1,
  'n-services-per-hh' => 1,
  'hh-init-eco-habits' => 1,
  'range-hh-init-eco' => 1,
  'p-criminal' => 1,
  'homophily-min' => 1,
  'homophily-max' => 1,
  'tolerance-crime' => 1,
  'tolerance-money' => 1,
  'tolerance-hetero' => 1,
  'tolerance-racism' => 1,
  'forgetting-crime' => 1,
  'forgetting-money' => 1,
  'forgetting-hetero' => 1,
  'forgetting-racism' => 1,
  'forgiveness-crime' => 1,
  'forgiveness-money' => 1,
  'forgiveness-hetero' => 1,
  'forgiveness-racism' => 1,
  'network?' => 1,
  'circles-max-move' => 1,
  'circles-max-move-work' => 1,
  'iv-mtg-mean' => 1,
  'iv-habit-max' => 1,
  'iv-nrg-min' => 1,
  'iv-min-dur' => 1,
  'iv-max-dur' => 1,
  'climate' => 1,
  'climate-calib-y-start' => 1,
  'climate-calib-y-end' => 1,
  'trust-ret' => 1,
  'moves-per-tick' => 1,
  'options-per-move' => 1,
  'n-daily-visits' => 1,
  'networked-unhappiness?' => 1,
  'visit-d-trust' => 1,
  'mtg-d-trust' => 1,
  'min-eco-habits' => 1,
  'eth-1-protest-min' => 1,
  'eth-ge2-protest-min' => 1,
  'kwh-per-m2' => 1,
  'k-per-kwh' => 1,
  'hh-eco-pp' => 1,
  'p-crime' => 1,
  'crime-benefit' => 1,
  'crime-cost' => 1,
  'crime-d-trust' => 1,
  'money-d-trust' => 1,
  'hetero-d-trust' => 1,
  'racism-d-trust' => 1,
  'n-unhappy-move' => 1,
);

# Logbook function

sub logbook {
  my @msg = @_;

  my ($sec, $min, $hr, $day, $mon, $yr) = gmtime();
  my $cmd = (File::Spec->splitpath($0))[2];
  print "$cmd log (",
    sprintf("%04d-%02d-%02dT%02d:%02d:%02d", $yr + 1900, $mon, $day, $hr, $min, $sec),
    "): ", join("", @msg), "\n";
}

# Process command-line arguments

if(scalar(@ARGV) > 0 && $ARGV[0] eq "--help") {
  print STDERR "Usage: $0 [--iv2-start <year>] [--iv2-stop <year>] [--rent-options <opt1,opt2,...>] ",
    "[--building-years <yyyy1,yyyy2,yyyy3,...>] [--districts <burgh1,burgh2,burgh3,...>] ",
    "[--n-sample <n>] [--sim-start <year>] [--sim-stop <year>] [--output-stem <filename stem>] ",
    "[--nlogo.py <path>] [--concur <n>] [--project <wckey>] [--gigaram <g>] [--version <nlogo v>]\n";
  print STDERR "\tDefaults:\n\t\t--iv2-start $iv2_start\n\t\t--iv2-stop $iv2_stop\n\t\t",
    "--rent-options ", join(",", @iv2_rent_options), "\n\t\t--building-years ",
    join(",", @iv2_bldg_years), "\n\t\t--districts ", join(",", @districts),
    "\n\t\t--n-sample $n_sample\n\t\t--sim-start $sim_start\n\t\t--sim-stop $sim_stop",
    "\n\t\t--output-stem $out_stem\n\t\t--nlogo.py $nlogo_py\n\t\t--concur $concur\n\t\t--project ",
    "$project\n\t\t--gigaram $gigaram\n\t\t--version $version\n";
  exit(1);
}

while($ARGV[0] =~ /^-/) {
  my $opt = shift(@ARGV);

  if($opt eq "--iv2-start") {
    $iv2_start = shift(@ARGV);
  }
  elsif($opt eq "--iv2-stop") {
    $iv2_stop = shift(@ARGV);
  }
  elsif($opt eq "--rent-options") {
    @iv2_rent_options = split(/,/, shift(@ARGV));
  }
  elsif($opt eq "--building-years") {
    @iv2_bldg_years = split(/,/, shift(@ARGV));
  }
  elsif($opt eq "--districts") {
    @districts = split(/,/, shift(@ARGV));
  }
  elsif($opt eq "--n-sample") {
    $n_sample = shift(@ARGV);
  }
  elsif($opt eq "--sim-start") {
    $sim_start = shift(@ARGV);
  }
  elsif($opt eq "--sim-stop") {
    $sim_stop = shift(@ARGV);
  }
  elsif($opt eq "--output-stem") {
    $out_stem = shift(@ARGV);
  }
  elsif($opt eq "--nlogo.py") {
    $nlogo_py = shift(@ARGV);
  }
  elsif($opt eq "--concur") {
    $concur = shift(@ARGV);
    die "--concur must be > 0 ($concur)\n" if $concur <= 0;
  }
  elsif($opt eq "--project") {
    $project = shift(@ARGV);
  }
  elsif($opt eq "--gigaram") {
    $gigaram = shift(@ARGV);
  }
  elsif($opt eq "--version") {
    $version = shift(@ARGV);
  }
  else {
    print STDERR "Option $opt not recognized; try --help\n";
  }
}

# Log inputs

&logbook("Second intervention start year: $iv2_start");
&logbook("Second intervention stop year: $iv2_stop");
&logbook("Second intervention rent choices: ", join(", ", @iv2_rent_options));
&logbook("Second intervention building years: ", join(", ", @iv2_bldg_years));
&logbook("Second intervention districts: ", join(", ", @districts));
&logbook("Number of samples per intervention file: $n_sample");
&logbook("Simulation starts on first day of: $sim_start");
&logbook("Simulation stops on last day of: $sim_stop");
&logbook("Stem to use for output file names: ", $out_stem);
&logbook("Path to write in scripts for nlogo.py: ", $nlogo_py);
&logbook("Number of concurrent runs: ", $concur);
&logbook("SLURM wckey project ID: ", $project);
&logbook("Gibibytes of RAM per run: ", $gigaram);
&logbook("NetLogo version to use: ", $version);

# Globals

my $n_ticks = &elapsed_days($sim_start, 1, $sim_stop, 12);

&logbook("Simulation will run for $n_ticks ticks");

my %params = (
  'apartments-in-houses?' => ['true'],
  'circles-max-move' => [5, 20],
  'circles-max-move-work' => [3, 20],
  'climate' => ['RCP8.5'],
  'climate-calib-y-end' => [1950],
  'climate-calib-y-start' => [1850],
  'crime-benefit' => [1000, 100000],
  'crime-cost' => [100, 2000],
  'crime-d-trust' => [0, 0.1],
  'daylight-p' => [0.833],
  'dwellings-per-terrace' => [6, 15],
  'dwellings-per-tower-block' => [20, 50],
  'en-eff-decay' => [0.0001, 0.01],
  'en-eff-dk-p-yr' => [0.0001, 0.01],
  'eth-1-max-reach' => [5, 20],
  'eth-1-max-trust' => [0.75, 1],
  'eth-1-min-reach' => [0, 5],
  'eth-1-min-trust' => [0.5, 0.75],
  'eth-1-protest-min' => [1, 100],
  'eth-1-work-reach' => [5, 20],
  'eth-ge2-max-reach' => [4, 16],
  'eth-ge2-max-trust' => [0.5, 1],
  'eth-ge2-min-reach' => [0, 4],
  'eth-ge2-min-trust' => [0.2, 0.5],
  'eth-ge2-protest-min' => [1, 100],
  'eth-ge2-work-reach' => [4, 16],
  'forgetting-crime' => [100, 1000],
  'forgetting-hetero' => [50, 250],
  'forgetting-money' => [50, 250],
  'forgetting-racism' => [100, 1000],
  'forgiveness-crime' => [0, 1000],
  'forgiveness-hetero' => [50, 250],
  'forgiveness-money' => [50, 250],
  'forgiveness-racism' => [100, 1000],
  'HBS-year' => [2006],
  'hetero-d-trust' => [0, 0.1],
  'hh-eco-pp' => [0, 0.1],
  'hh-file' => ['%hh_file%'],
  'hh-file-freq-units' => ['years'],
  'hh-file-write-frequency' => [1],
  'hh-init-eco-habits' => [0, 2],
  'homophily-max' => [0.75, 1],
  'homophily-min' => [0, 0.75],
  'income-sd' => [100, 10000],
  'intervention-file' => ['%iv_file%'],
  'iv-habit-max' => [0.1, 0.9],
  'iv-max-dur' => [540],
  'iv-min-dur' => [90],
  'iv-mtg-mean' => [5, 20],
  'iv-nrg-min' => [0.1, 0.7],
  'k-per-kwh' => [0, 5],
  'kwh-per-m2' => [0, 20],
  'many-iv-p-bldg?' => ['false'],
  'max-cycle-dist' => [1, 10],
  'max-floor-space-diff' => [10, 50],
  'max-walk-dist' => [0, 5],
  'min-eco-habits' => [0.2, 0.8],
  'model-area' => ['Jarva/Stockholm'],
  'money-d-trust' => [0, 0.1],
  'moves-per-tick' => [10, 100],
  'mtg-d-trust' => [0, 1],
  'n-activities' => [100, 500],
  'n-daily-visits' => [1, 20],
  'n-ethnicities' => [2, 5],
  'n-households' => [4000, 8000],
  'n-rand-iv' => [0],
  'n-services' => [20, 100],
  'n-services-per-hh' => [1, 20],
  'n-unhappy-move' => [50, 1000],
  'network?' => ['true'],
  'networked-unhappiness?' => ['true', 'false'],
  'only-rented?' => ['true'],
  'options-per-move' => [1, 6],
  'override-eth?' => ['true'],
  'p-crime' => [0, 0.1],
  'p-criminal' => [0, 0.2],
  'p-cycle' => [0, 1],
  'p-eth-1' => [0, 1],
  'racism-d-trust' => [0, 0.1],
  'range-crime' => [0, 1],
  'range-hetero' => [0, 1],
  'range-hh-init-eco' => [0, 1],
  'range-money' => [0, 1],
  'range-racism' => [0, 1],
  'rent-per-m2' => [40, 100],
  'routines-include-routes?' => ['false'],
  'scb-year' => [2013],
  'start-year' => [$sim_start],
  'tolerance-crime' => [1, 20],
  'tolerance-hetero' => [1, 100],
  'tolerance-money' => [1, 50],
  'tolerance-racism' => [1, 100],
  'trust-diff' => [0, 1],
  'trust-ret' => [0, 0.2],
  'visit-d-trust' => [0, 0.1],
  'xp-food?' => ['true'],
  'xp-clothes?' => ['true'],
  'xp-leisure?' => ['true'],
  'xp-health?' => ['true'],
  'xp-comms?' => ['true'],
  'xp-home?' => ['true'],
  'xp-childcare?' => ['true'],
  'xp-goods?' => ['true'],
  'xp-transport?' => ['true'],
  'xp-narcotics?' => ['true'],
);

# Data (from Persson, A. and H{\"o}gdal (2015) "Sustainable cities --
#   energy efficiency renovation and its economy. City of Stockholm, Environment
#   and Health Administration, Energy Centre, SE-104 20 Stockholm.")
#   https://paperzz.com/doc/8186277/sustainable-cities

my @data = ( {
    'year' => 1974,
    'district' => "Husby",
    'trenov' => [2010, 3, 2011, 4],
    'energy' => [181, 125],
    'rent' => [803, 1230]
  }, # Trondheim 4; Trondheimsgatan 28 (pp. 22-23)
  {
    'year' => 1974,
    'district' => "Husby",
    'trenov' => [2011, 1, 2012, 12],
    'energy' => [195, 122],
    'rent' => [817, 953]
  }, # Trondheim 4; Trondheimsgatan 30 (pp. 24-25)
  {
    'year' => 1971,
    'district' => "Rinkeby",
    'trenov' => [2011, 4, 2012, 10],
    'energy' => [138, 83],
    'rent' => [817, 970]
  }, # Kvarnseglet 2; G{\"a}rdebyplan 8-26 (pp. 26-27)
  {
    'year' => 1972,
    'district' => "Rinkeby",
    'trenov' => [2012, 4, 2013, 1],
    'energy' => [135, 93],
    'rent' => [926, 957]
  }, # Storkvarnen 4; V{\"a}sterby Backe 26-30 (pp. 28-29)
  {
    'year' => 1974,
    'district' => "Akalla",
    'trenov' => [2011, 4, 2012, 8],
    'energy' => [137, 89],
    'rent' => [825, 1020]
  }, # Nystad 7; Sibeliusg{\aa}ngen 2 (pp. 30-31)
  {
    'year' => 1975,
    'district' => "Akalla",
    'trenov' => [2012, 11, 2013, 12],
    'energy' => [134, 96],
    'rent' => [844, 1020]
  }  # Nystad 8; Sibelius{\aa}ngen 4 (pp. 32-33)
);

sub elapsed_days {
  my ($y1, $m1, $y2, $m2) = @_;

  my @mdays = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

  my $n_days = 0;

  # Very very lazy

  if($y1 < $y2) {
    for(my $m = $m1; $m <= 12; $m++) {
      $n_days += $mdays[$m];
      $n_days++ if($m == 2 && $y1 % 4 == 0 && $y1 % 100 != 0);
    }
    for(my $y = $y1 + 1; $y < $y2; $y++) {
      $n_days += ($y % 4 == 0 && $y % 100 != 0) ? 366 : 365;
    }
  }
  for(my $m = 1; $m <= $m2; $m++) {
    $n_days += $mdays[$m];
    $n_days++ if($m == 2 && $y2 % 4 == 0 && $y2 % 100 != 0);
  }

  return $n_days;
}

sub add_months {
  my ($y1, $m1, $madd) = @_;

  my $y = $y1;
  my $m = $m1 + $madd;

  # Also lazy
  while($m > 12) {
    $y++;
    $m -= 12;
  }

  return ($y, $m);
}

sub create_iv_files {
  my ($stem) = @_;

  my $mean_rent = 0;
  for(my $i = 0; $i <= $#iv2_rent_options; $i++) {
    $mean_rent += $iv2_rent_options[$i];
  }
  $mean_rent /= scalar(@iv2_rent_options);

  my @file_names;

  my $tex_file = "$stem-iv.tex";

  open(TEX, ">", $tex_file) or die "Cannot create intervetion table file $tex_file: $!\n";
  print TEX "\\begin{table}\n\t\\centering\n\t\\caption{Intervention settings}\n\t\\label{tab:iv}\n";
  print TEX "\t\\begin{tabular}{|l|c|c|}\n\t\t\\hline\n\t\t\\textbf{Intervention feature} & ".
    "\\textbf{Pilot} & \\textbf{Rollout} \\\\\n\t\t\\hline\n";

  my %pilot;
  my %rollout;

  my $n = 0;
  foreach my $solve ("false,false,false,false", "true,true,true,true") {
    $n++;
    my $slv_name = ($solve =~ /false/ ? "Sf" : "St");

    foreach my $lang ("eth-1", "all") {
      my $lng_name = "L$lang";
      $lng_name =~ s/-1$//;

      foreach my $rent ([$mean_rent], \@iv2_rent_options) {
        my $rnt_name = "R".scalar(@$rent);
        my $rent_entry = join("|", @$rent);

        foreach my $habit ("1", "iv-habit-max") {
          my $hbt_name = ($habit eq "1") ? "H1" : "Hx";
          my $mtg = ($habit eq "1") ? 0 : "iv-mtg-mean";
          my $mtg_name = ($habit eq "1") ? "M0" : "Mx";

          # make a filename and open it

          my $file_name = "$stem-$slv_name-$lng_name-$rnt_name-$hbt_name-$mtg_name.csv";
          push(@file_names, $file_name);
          open(FP, ">", $file_name) or die "Cannot create intervention file $file_name: $!\n";

          # print header

          print FP "start,duration,crime,money,hetero,racism,lang,rent,energy,habits,meetings,borough,built,size\n";

          # print all the pilot interventions fom @data

          foreach my $datum (@data) {
            my $year = $$datum{'year'};
            my $district = $$datum{'district'};
            my $trenov = $$datum{'trenov'};
            my $energy = $$datum{'energy'};
            my $rent = $$datum{'rent'};
            my $tick_dur = &elapsed_days($$trenov[0], $$trenov[1], $$trenov[2], $$trenov[3]);

            my $d_rent_entry = $$rent[1] / $$rent[0];
            my $d_energy_entry = $$energy[1] / $$energy[0];

            print FP "y$$trenov[0]m", sprintf("%02d", $$trenov[1]),
              ",$tick_dur,$solve,$lang,$d_rent_entry,",
              "$d_energy_entry,$habit,$mtg,$district,$year|$year,",
              $params{'dwellings-per-tower-block'}[0], "\n";


            $pilot{'Address other issues?'}->{$solve =~ /false/ ? "No" : "Yes"} = 1;
            $pilot{'Only use Swedish?'}->{$lang eq "eth-1" ? "Yes" : "No"} = 1;
            $pilot{'Choice over upgrade?'}->{"No"} = 1;
            push(@{$pilot{'Upgrade energy saving'}}, 100 * ($$energy[0] - $$energy[1]) / $$energy[0]);
            $pilot{'Education on saving energy?'}->{$habit eq "1" ? "No" : "Yes"} = 1;
            $pilot{'Meetings with stakeholders?'}->{$habit eq "1" ? "No" : "Yes"} = 1;
            push(@{$pilot{'Year of construction of affected buildings'}}, $year);

          }

          # Print the second intervention. This is done in a series of larger-scale
          # projects starting with the oldest buildings and working up to the newer
          # buildings, in all areas

          # Number of months over which the second intervention projects may start
          my $iv2_n_months = (1 + $iv2_stop - $iv2_start) * 12;

          # Increment (in months) of project starts for the second intervention
          my $iv2_month_incr = int($iv2_n_months / (scalar(@districts) * scalar(@iv2_bldg_years)));

          for(my $j = 0; $j <= $#districts; $j++) {
            # Loop through all the building years to create projects for each
            for(my $i = 0; $i <= $#iv2_bldg_years; $i++) {
              # Determine building year range given $i
              my $year_min = ($i == 0) ? 1900 : $iv2_bldg_years[$i - 1];
              my $year_max = $iv2_bldg_years[$i] - 1;

              # Determine start tick and duration ticks for this project

              my ($iv_y1, $iv_m1) = &add_months($iv2_start, 1, (($i * scalar(@districts)) + $j) * $iv2_month_incr);

              print FP "y${iv_y1}m", sprintf("%02d", $iv_m1), ",random,$solve,",
                "$lang,$rent_entry,iv-nrg-min,$habit,$mtg,$districts[$j],",
                "$year_min|$year_max,", $params{'dwellings-per-terrace'}[0], "\n";

              $rollout{'Address other issues?'}->{$solve =~ /false/ ? "No" : "Yes"} = 1;
              $rollout{'Only use Swedish?'}->{$lang eq "eth-1" ? "Yes" : "No"} = 1;
              $rollout{'Choice over upgrade?'}->{scalar(@$rent) == 1 ? "No" : "Yes"} = 1;
              $rollout{'Upgrade energy saving'} = "\$Delta E\$";
              $rollout{'Education on saving energy?'}->{$habit eq "1" ? "No" : "Yes"} = 1;
              $rollout{'Meetings with stakeholders?'}->{$habit eq "1" ? "No" : "Yes"} = 1;
              push(@{$rollout{'Year of construction of affected buildings'}}, $year_min, $year_max);

            }
          }

          # close the file

          close(FP);
          &logbook("Created intervention file $file_name");
        }
      }
    }
  }

  foreach my $key ('Address other issues?', 'Only use Swedish?', 'Choice over upgrade?',
    'Education on saving energy?', 'Meetings with stakeholders?') {

    $pilot{$key} = join("/", sort {$a cmp $b} keys(%{$pilot{$key}}));
    $rollout{$key} = join("/", sort {$a cmp $b} keys(%{$rollout{$key}}));
  }

  my $pt_en = 0;
  my $pt_n = 0;
  foreach my $en (@{$pilot{'Upgrade energy saving'}}) {
    $pt_en += $en;
    $pt_n++;
  }
  $pilot{'Upgrade energy saving'} = sprintf("%.2f", $pt_en / $pt_n)."\\%";
  my $py_min = ${$pilot{'Year of construction of affected buildings'}}[0];
  my $py_max = $py_min;
  foreach my $yr (@{$pilot{'Year of construction of affected buildings'}}) {
    $py_min = ($yr < $py_min) ? $yr : $py_min;
    $py_max = ($yr > $py_max) ? $yr : $py_max;
  }
  $pilot{'Year of construction of affected buildings'} = "$py_min-$py_max";

  my $ry_min = ${$rollout{'Year of construction of affected buildings'}}[0];
  my $ry_max = $ry_min;
  foreach my $yr (@{$rollout{'Year of construction of affected buildings'}}) {
    $ry_min = ($yr < $ry_min) ? $yr : $ry_min;
    $ry_max = ($yr > $ry_max) ? $yr : $ry_max;
  }
  $rollout{'Year of construction of affected buildings'} = "$ry_min-$ry_max";

  foreach my $feature ('Address other issues?', 'Only use Swedish?', 'Choice over upgrade?',
    'Upgrade energy saving', 'Meetings with stakeholders?', 'Year of construction of affected buildings') {

    print TEX "\t\t$feature & $pilot{$feature} & $rollout{$feature} \\\\\n";
  }

  print TEX "\t\t\\hline\n\t\\end{tabular}\n\\end{table}\n";

  close(TEX);
  &logbook("Created intervention table file $tex_file");

  return @file_names;
}

sub save_sample_tex {
  my ($stem) = @_;

  my $hold_file = "$stem-hold.tex";
  my $vary_file = "$stem-vary.tex";
  my $other_file = "$stem-other.tex";
  open(HOLD, ">", $hold_file) or die "Cannot create hold parameter file $hold_file: $!\n";
  open(VARY, ">", $vary_file) or die "Cannot create vary parameter file $vary_file: $!\n";
  open(OTHER, ">", $other_file) or die "Cannot create other parameter file $other_file: $!\n";

  print HOLD "\\begin{table}\n\t\\centering\n\t\\caption{Parameters kept constant}\n".
    "\t\\label{tab:param-hold}\n";
  print VARY "\\begin{table}\n\t\\centering\n\t\\caption{Parameters varied}\n".
    "\t\\label{tab:param-vary}\n";
  print OTHER "\\begin{table}\n\t\\centering\n\t\\caption{Settings for model ".
    "parameters not mentioned in the ODD}\n\t\\label{tab:param-other}\n";

  print HOLD "\t\\begin{tabular}{|l|r|}\n\t\t\\hline\n\t\t\\textbf{Parameter} & ".
    "\\textbf{Value Used} \\\\\n\t\t\\hline\n";
  print VARY "\t\\begin{tabular}{|l|r|r|}\n\t\t\\hline\n\t\t\\textbf{Parameter} ".
    "& \\textbf{Minimum} & \\textbf{Maximum} \\\\\n\t\t\\hline\n";
  print OTHER "\t\\begin{tabular}{|l|l|r|}\n\t\t\\hline\n\t\t\\textbf{Parameter} ".
    "& \\textbf{Varied?} & \\textbf{Setting(s)} \\\\\n\t\t\\hline\n";

  foreach my $param (sort {$a cmp $b} keys(%params)) {
    my $settings = $params{$param};
    if(defined($paper_parameters{$param})) {
      if(scalar(@$settings) == 1) {
        print HOLD "\t\t\\texttt{$param} & ";
        if($$settings[0] =~ /^[+-]?\d*\.?\d+([eE][+-]?\d+)?$/) {
          print HOLD $$settings[0];
        }
        elsif($$settings[0] eq 'true' || $$settings[0] eq 'false') {
          print HOLD "\\texttt{$$settings[0]}"
        }
        else {
          print HOLD "\\texttt{\"$$settings[0]\"}";
        }
        print HOLD " \\\\\n";
      }
      else {
        print VARY "\t\t\\texttt{$param} & ";
        if($$settings[0] eq 'true' || $$settings[0] eq 'false') {
          print VARY "\\texttt{$$settings[0]} & \\texttt{$$settings[$#$settings]}";
        }
        else {
          print VARY "$$settings[0] & $$settings[$#$settings]";
        }
        print VARY " \\\\\n";
      }
      $paper_parameters{$param} = 0;
    }
    else {
      print OTHER "\t\t\\texttt{$param} & ";
      if(scalar(@$settings) == 1) {
        print OTHER "No & $$settings[0] \\\\\n";
      }
      else {
        print OTHER "Yes & $$settings[0]-$$settings[$#$settings] \\\\\n";
      }
    }
  }

  print HOLD "\t\t\\hline\n\t\\end{tabular}\n\\end{table}\n";
  print VARY "\t\t\\hline\n\t\\end{tabular}\n\\end{table}\n";
  print OTHER "\t\t\\hline\n\t\\end{tabular}\n\\end{table}\n";

  close(HOLD);
  close(VARY);
  close(OTHER);

  &logbook("Created parameters held constant table file $hold_file");
  &logbook("Created varied parameters table file $vary_file");
  &logbook("Created other parameters table file $other_file");

  foreach my $param (sort { $a cmp $b } %paper_parameters) {
    if($paper_parameters{$param} != 0) {
      &logbook("Paper parameter $param has not been given a setting");
      warn("WARNING: Paper parameter $param not assigned!");
    }
  }
}

sub build_sample_files {
  my @iv_files = @_;

  my @file_names;
  foreach my $iv_file (@iv_files) {
    my $file_name = substr($iv_file, 0, -4)."-param.csv";
    my $hh_file = substr($iv_file, 0, -4)."-hh.csv";
    push(@file_names, $file_name);

    open(FP, ">", $file_name)
      or die "Cannot create sample parameter file $file_name for intervention file $iv_file: $!\n";

    print FP "parameter,type,setting,minimum,maximum\n";

    foreach my $param (sort {$a cmp $b} keys(%params)) {
      my $settings = $params{$param};
      my $type = 'numeric';
      if($$settings[0] eq 'true' || $$settings[0] eq 'false') {
        $type = 'boolean';
      }
      elsif($$settings[0] !~ /^[+-]?\d*\.?\d+([eE][+-]?\d+)?$/) {
        $type = 'string';
      }

      my %subs;
      for(my $i == 0; $i <= $#$settings; $i++) {
        if($$settings[$i] eq '%iv_file%') {
          my @cp = @$settings;
          $subs{$param} = \@cp;
          $$settings[$i] = "\"$iv_file\"";
        }
        elsif($$settings[$i] eq '%hh_file%') {
          my @cp = @$settings;
          $subs{$param} = \@cp;
          $$settings[$i] = "\"$hh_file\"";
        }
      }

      print FP "$param,$type,$$settings[0],$$settings[0],$$settings[$#$settings]\n";

      foreach my $sub (keys(%subs)) {
        $params{$sub} = $subs{$sub};
      }
    }

    close(FP);

    &logbook("Created sample parameter file $file_name for intervention file $iv_file");
  }
  return @file_names;
}

# Main
&save_sample_tex($out_stem);
my @iv_files = &create_iv_files($out_stem);
my @sample_files = &build_sample_files(@iv_files);
my $setup_file = "${out_stem}-setup.sh";
my $run_file = "${out_stem}-run.sh";
open(SETUP, ">", $setup_file) or die "Cannot create setup shell script $setup_file: $!\n";
open(RUN, ">", $run_file) or die "Cannot create run shell script $run_file: $!\n";
print SETUP '#!/bin/sh', "\n";
print RUN '#!/bin/sh', "\n";
my $n_runs = 0;
foreach my $sample_file (@sample_files) {
  my $sample_stem = substr($sample_file, 0, -4);
  my $xml = "${sample_stem}.xml";
  my $sh = "${sample_stem}.sh";
  print SETUP "$nlogo_py -v $version -g $gigaram --no-final-save --no-progress --limit-concurrent $concur --mc-expt $sample_stem wolverine-v2.nlogo montq $sample_file $n_ticks $n_sample $xml $sh\n";
  print RUN "sbatch --wckey=$project $sh\n";
  $n_runs += $n_sample;
}
close(SETUP);
chmod(0755, $setup_file) or die "Cannot make setup shell script $setup_file executable: $!\n";
&logbook("Created setup script $setup_file");
close(RUN);
chmod(0755, $run_file) or die "Cannot make run shell script $run_file executable: $!\n";
&logbook("Created run script $run_file");
&logbook("Experiment will create $n_runs runs");
exit(0);
