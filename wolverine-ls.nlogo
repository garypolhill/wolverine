extensions [ lt gis table csv math mgr ]


; global variables
globals [

  gis-dir ; directory where GIS data is stored
  ;;; Housing Association ("ha") ;;;
  ha-finance ; finance available to housing association

  boroughs-stats-table ; a table where stats about each borough is stored (e.g. crime rate, percent of foreign born, etc.)

  env-weather-list  ; a list containing all average temperature from 1961 to 2100 in the form of [year avg-temp sd-temp]
  env-monthly-mean  ; a list containing calibrated mean monthly temperature observations from Stockholm
  env-monthly-sd    ;
  env-year-mean     ; a list containing calibrated mean annual temperature observations from Stockholm
  today-temperature ; today's temperature
  yesterday-temperature ; yesterday's temperature
  this-year         ; current year
  this-month        ; current month
  this-day          ; current day in month
  n-months
  n-years

  patch-km ; width of a patch in kilometers
  max-walk
  max-cycle

  apartment-buildings
  service-buildings
  activity-buildings

  route-table

  warnings
  notes

  is-stockholm?
  is-malmo?

  n-crimes
  n-hate-crimes
  n-in-debt
  n-too-diverse
  n-moved

  move-waiting-list ; waiting list to move house

  scb-building-tenancy
  scb-building-year
  scb-building-floor
  scb-household-size
  scb-household-floor
  scb-household-tenancy
  scb-household-type
  scb-household-decile
  scb-household-expense

  scb-xp-food
  scb-xp-clothes
  scb-xp-leisure
  scb-xp-health
  scb-xp-comms
  scb-xp-home
  scb-xp-childcare
  scb-xp-goods
  scb-xp-transport
  scb-xp-narcotics
  scb-cpi-year
  scb-cpi-index

  daylight-hours
  latitude

  error? ; has there been an error?
]

breed [ boroughs borough ]
boroughs-own [
  borough-name
  borough-n-crimes
  data-population
  data-flats
  data-social-flats
  data-foreign-born-p
  data-employed-p
  data-benefits-p
  data-benefits-kr
  data-mean-income-kr
  data-omradesfakta-year
  borough-scb-id ; identifier from SCB data 0184 is Solna (containing Jarva); 1280 is Malmo
]

breed [ interventions intervention ]
interventions-own [
  intervention-start ; tick at which intervention starts
  intervention-duration ; how long the intervention lasts for
  intervention-notification-information ; list of what households are told
  intervention-notification-languages ; list of ethnicities
  intervention-rent-change-options ; list of options
  intervention-energy-efficiency-change ; change to energy efficiency of apartments
  intervention-household-eco-habits-change ; change to household habits from environmental education
  intervention-meetings ; number of meetings with residents
  intervention-buildings ; buildings affected
  intervention-hh-apartments ; list of household-apartment pairs so we can move people back in
  intervention-upgrade-choices ; list of building-upgrade pairs so we can change the rents
  intervention-active? ; is the intervention on-going?
  intervention-stage ; what stage are we at in the intervention
  intervention-building-progress ; which building are we on?
  intervention-borough
  intervention-min-building-year
  intervention-max-building-year
  intervention-min-n-dwellings
]

breed [ junctions junction ]
junctions-own [
  junction-type
  dijkstra-visited?
  dijkstra-previous
  dijkstra-distance
]

undirected-link-breed [ routes route ]
routes-own [
  road-patches
  route-type
]

breed [ routefinders routefinder ]
routefinders-own [
  routefinder-path ; list of patches visited
  routefinder-finished? ; are there no more patches the routefinder can visit?
  routefinder-useful? ; did the routefinder get somewhere useful?
]


breed [ households household ]
households-own [
  household-apartment ; the apartment where the household lives
  household-borough ; borough where household lives
  household-employed? ; is the household employed? for sake of simplicity household employement is reduced to TRUE/FALSE
  household-activity ; list of activity buildings at which the household is employed
  household-services ; list of services the household goes to
  household-greenspace ; locations of greenspaces the household goes to

  household-income ; monthly household income
  household-finance ; finance available to the household
  household-expenses ; monthly expenses for the household (based on Household Budget Survey) and error margin (two-item list)
  household-habits-eco ; enviromental habits (affects energy consumption and thus cost)
  household-criminal? ; is (a member of) the household one that does robbery, burglary, car or bicycle theft, or theft from a car
  household-cycles? ; does the household use a bicycle
  household-gender
  household-size
  household-ethnicity
  household-homophily
  household-floor-space
  household-tenancy
  household-trust ; in authority 0 no trust 1 full trust
  household-baseline-trust
  household-tolerance

  household-routine ; set of patches that the household visits
  household-todays-routine ; set of patches the household will visit today
  household-reach ; social circles parameter for this household
  household-workplace-reach ; social circles parameter for this household
  household-n-encounters
  household-n-same-encounters

  ; unhappinesses -- memories of things that are upsetting as lists of ticks when they occurred

  unhappiness-money ; list of ticks when household-finance < 0
  unhappiness-racism ; list of days when housheold was a victim of racism
  unhappiness-crime ; list of days when household was a victim of crime
  unhappiness-heterophily ; list of days when household homophily breached

  consecutive-days-unhappy

  household-protesting?

  household-forgiveness-crime ; number of ticks since last time an unhappiness event occurred that leads to older occasions being forgotten
  household-forgiveness-racism
  household-forgiveness-hetero
  household-forgiveness-money
  household-forgetting-crime ; events older than this (in ticks) will be let go if enough time has elapsed
  household-forgetting-racism
  household-forgetting-hetero
  household-forgetting-money
  household-tolerance-crime ; length of an unhappiness list above which a household can be said to be 'unhappy' about that thing
  household-tolerance-racism
  household-tolerance-hetero
  household-tolerance-money

  household-in-intervention? ; Pause moving if in an intervention

  ; observation data

  days-unhappy
  days-unhappy-money
  days-unhappy-racism
  days-unhappy-crime
  days-unhappy-hetero
  days-protesting
  n-move-requests
  n-moves
]

; links connecting households to each other
undirected-link-breed [social-ties social-tie]
social-ties-own [
  social-tie-type ; "local-link" means the link connects the household to a neighbour household, "global-link" means the link connect the household with someone in the city (not geo close)
]

; patches can be areas or roads
patches-own [
  patch-is-buildings-area? ; TRUE if patch is a type of area with buildings over it
  patch-is-road? ; TRUE If patch is a type of road
  patch-borough ; borough name from shapefile
  patch-inside-map? ; TRUE if patch is within the map; FALSE otherwise
  patch-type ; list of types of patch (building and/or road)
  patch-centroid? ; true if the patch is the centroid of the polygon
  patch-id ; from GIS file (OSM ID e.g. for buildings)
  patch-subtype ; any further useful data from GIS
  patch-junctions ; list of types for which this patch is a junction
]

breed [ buildings building ]
buildings-own [
  building-type
  building-subtype
  building-id
  n-dwellings
  building-year
  last-renovation
  building-footprint
  building-scb-type ; type from SCB data
  building-apartments
  building-intervention-planned? ; is the building already part of an intervention?
]

breed [ apartments apartment ]
apartments-own [
  ;;; Basic info ;;;
  apartment-building ; apartment's building
  apartment-size ; apartment's square meters (m2)

  apartment-household ; the household living here
  apartment-occupied? ; there is a household living here
  ;;; Rent, energy, and maintenance ;;;
  apartment-scb-tenancy ; from SCB data
  apartment-rent ; apartment's rent (SEK/month)
  apartment-energy-consumption ; apartment's daily energy consumption (kWh/day)
  apartment-energy-cost ; apartment's daily energy cost (SEK/day)
  apartment-energy-bill ; accumulated energy cost
  apartment-energy-efficiency ; apartment's energy efficiency (default=1, renovated=0.67) ; higher values means less efficiency
  apartment-energy-efficiency-decay-rate ; decay of energy efficiency for the apartment
  ;;; Renovation ;;;
  apartment-renovated? ; TRUE if apartment has been renovated
  apartment-renovation-time ; expected time to renovate the apartments (months)
  apartment-renovation-status ; "NA" for non renovated; "on-going" for on-going renovation; "completed" for completed renovation
  apartment-newness ; last renovation year or building year, whichever is newer
]


breed [ activities activity ]
activities-own [
  activity-building
]

breed [ services service ]
services-own [
  service-building
]


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP
;;;;;;;;;;;;;;;;;;;;;;;;;
;{procedures for the setup of the models (GIS, patches, agents, etc.)}

;{world}
;{main setup procedure}
to setup
  ca ;  Combines the effects of clear-globals, clear-ticks, clear-turtles, clear-patches, clear-drawing, clear-all-plots, and clear-output.
  reset-timer
  set error? false

  print-progress "setup started"

  set is-stockholm? false
  set is-malmo? false

  (ifelse model-area = "Jarva/Stockholm" [
    set latitude 59.3293
    set is-stockholm? true
  ] model-area = "Augustenborg/Malmo" [
    set latitude 55.5600
    set is-malmo? true
  ] [
    output-error (word "Unrecognized model-area setting: \"" model-area "\"")
  ])
  output-note (word "Modelling " model-area ", lat. " latitude)
  print-progress "loading SCB data"

  initialize-scb "Data/housing"

  print-progress "initializing patch variables"

  ask patches [
    patches-init-variables
  ]

  print-progress "loading GIS data files"

  let gis-boundaries 0
  let gis-pois table:make
  let gis-buildings table:make
  let gis-roads table:make

  if is-stockholm? [
    set gis-dir "Data/gis-stockholm"

    set gis-boundaries gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-stadsdelar.shp")
    ; Load place of interests (pois)
    table:put gis-pois "A-pois-green" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-POIS-Green_areas.shp")
    table:put gis-buildings "A-service" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-POIS-Public_buildings.shp")
    table:put gis-pois "A-pois-water" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Water.shp")
    ; Load buildings/apartment
    table:put gis-buildings "A-apartment" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Buildings-Dwellings.shp")
    ; Load buildings/activities
    table:put gis-buildings "A-activity" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Buildings-Activities.shp")
    ; Load roads/roadways
    table:put gis-roads "R-roadway" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Roads-Roadways.shp")
    ; Load roads/cycleways
    table:put gis-roads "R-cycleway" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Roads-Cycleways.shp")
    ; Load roads/footways
    table:put gis-roads "R-footway" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Roads-Footways.shp")
    ; Load rails (file includes subways)
    table:put gis-roads "R-railway" gis:load-dataset (word gis-dir "/GIS-Stockholm-Jarva-Rail.shp")

  ]

  if is-malmo? [
    set gis-dir "Data/gis-malmo"

    set gis-boundaries gis:load-dataset (word gis-dir "/Augustenborg_Boundaries_CRS.shp")
    table:put gis-pois "from-file" gis:load-dataset (word gis-dir "/Augustenborg_POIS_CRS.shp")
    table:put gis-buildings "from-file" gis:load-dataset (word gis-dir "/Augustenborg_Buildings_CRS.shp")
    table:put gis-roads "from-file" gis:load-dataset (word gis-dir "/Augustenborg_Roads_CRS.shp")

  ]

  ; Define world limit based on gis data
  print-progress "defining world envelope"
  if is-number? gis-boundaries [
    output-error "No boundary data loaded"
  ]

  gis:set-world-envelope ;gis:envelope-of gis-boundaries
   (gis:envelope-union-of
    gis:envelope-of gis-boundaries
    gis-union-of-table gis-pois
    gis-union-of-table gis-buildings
    gis-union-of-table gis-roads
  )

  ; Load and draw various gis files
  ; Load boroughs boundaries

  let env-deg gis:world-envelope
  let env-y-deg abs (item 3 env-deg - item 2 env-deg)
  ; see table for phi = 60 degrees latitude in section entitled "Meridian distance on the ellipsoid" at https://en.wikipedia.org/wiki/Latitude
  set patch-km 111.412 * env-y-deg / world-height
  set max-walk max-walk-dist / patch-km
  set max-cycle max-cycle-dist / patch-km

  ; Draw borough boundaries
  print-progress "drawing map"
  gis:set-drawing-color black
  gis:draw gis-boundaries 1

  ; Find the centroid of each borough and assign the corresponding borough name
  print-progress "finding neighbourhood centroids"
  patches-areas-find-borough-centroids (gis-boundaries)

  ; Assign an area type to patches within the map {(gis-datafile) (patch-type) (color)}
  print-progress "finding areas with buildings and greenspace"

  foreach table:keys gis-buildings [ gis-data-key ->
    patches-assign-area-features (table:get gis-buildings gis-data-key) gis-data-key
  ]
  foreach table:keys gis-pois [ gis-data-key ->
    patches-assign-area-features (table:get gis-pois gis-data-key) gis-data-key
  ]
  foreach ["A-apartment" "A-activity" "A-service" "A-pois-green" "A-pois-water"] [ tp ->
    output-note (word (count patches with [member? tp patch-type]) " patches with type \"" tp "\" initialized")
  ]

  ; Create buildings over patches {(type of patch) (type of building) (size) (color) (shape)}
  print-progress "creating buildings (apartments, activities, and services)"

  set apartment-buildings buildings with [building-type = "A-apartment"]
  ask apartment-buildings [
    let n-apartments ifelse-value (building-subtype = "apartments") [
      dwellings-per-tower-block
    ] [
      ifelse-value (building-subtype = "terrace") [
        dwellings-per-terrace
      ] [
        ifelse-value apartments-in-houses? [ifelse-value (building-subtype = "detached") [1] [2] ] [0]
      ]
    ]
    hatch-apartments n-apartments [
      apartments-init-variables myself
    ]
  ]
  output-note (word count apartments " apartments in buildings created.")

  ask buildings [
    set building-apartments apartments with [ apartment-building = myself ]
  ]

  set activity-buildings buildings with [building-type = "A-activity"]

  ifelse n-activities < count activity-buildings [
    ask n-of n-activities activity-buildings [
      hatch-activities 1 [
        activities-init-variables myself
      ]
    ]
  ] [
    repeat n-activities [
      create-activities 1 [
        activities-init-variables one-of activity-buildings
      ]
    ]
  ]
  output-note (word count activities " buildings of type \"activity\" created.")

  set service-buildings buildings with [building-type = "A-service"]
  ifelse n-services < count service-buildings [
    ask n-of n-services buildings with [building-type = "A-service"] [
      hatch-services 1 [
        services-init-variables myself
      ]
    ]
  ] [
    repeat n-services [
      create-services 1 [
        services-init-variables one-of service-buildings
      ]
    ]
  ]
  output-note (word count services " buildings of type \"service\" created.")

  ; Map roads and cycleways to patches
  print-progress "mapping roads"
  foreach table:keys gis-roads [ gis-data-key ->
    patches-roads-assign-type (table:get gis-roads gis-data-key) gis-data-key
  ]
  foreach ["R-footway" "R-cycleway" "R-roadway" "R-railway"] [ tp ->
    output-note (word (count patches with [member? tp patch-type]) " patches with type \"" tp "\" initialized")
    if tp != "R-railway" [
      connect-road-network tp
    ]
  ]

  ; Create households, one per apartment
  print-progress "creating households and social network"

  create-households n-households [
    households-init-variables
  ]

  output-note (word count households " households created")
  ; Connect people
  if (network?) [
    print-progress "creating social network"
    households-create-network
  ]
  output-note (word count social-ties " ties in social network among households created")

  print-progress "creating household routines"
  let rt-time timer
  let i 0
  let n count households
  ask households [
    households-create-routine
    if timer > rt-time + 60 [
      set rt-time timer
      print-progress (word i " of " n " household routines done")
    ]
    set i i + 1
  ]

  set n-crimes 0
  set n-hate-crimes 0
  set n-too-diverse 0
  set n-in-debt 0
  set move-waiting-list lt:make

  ; Environment
  print-progress "reading weather data"
  env-read-weather-data
  set this-year start-year
  set this-month 1
  set this-day 1
  env-set-today-temperature

  ; Inverventions
  print-progress "reading/creating interventions"
  ifelse intervention-file != "" and intervention-file != "NA" and intervention-file != 0 [
    read-interventions intervention-file
  ] [
    repeat n-rand-iv [
      random-intervention
    ]
  ]


  ask patches [
    colour-patch
  ]

  set n-months 0
  set n-years 0

  print-progress "setup completed"

  reset-ticks
end

to-report gis-union-of-table [ a-table ]
  let union 0

  foreach table:keys a-table [ the-key ->
    ifelse is-number? union [
      set union gis:envelope-of table:get a-table the-key
    ] [
      set union gis:envelope-union-of union gis:envelope-of table:get a-table the-key
    ]
  ]

  if is-number? union [
    output-error "BUG: union requested of empty table"
  ]
  report union
end

to colour-patch
  let is-road? false
  let is-path? false
  let is-rail? false
  let is-bike? false
  let is-active? false
  let is-dwelling? false
  let is-serve? false
  let is-water? false
  let is-greenspace? false
  let is-in-borough? patch-borough != nobody
  let is-valid? true

  foreach patch-type [ pt ->
    (ifelse pt = "A-pois-water" [
      set is-water? true
    ] pt = "A-pois-green" [
      set is-greenspace? true
    ] pt = "A-service" [
      set is-serve? true
    ] pt = "A-apartment" [
      set is-dwelling? true
    ] pt = "A-activity" [
      set is-active? true
    ] pt = "R-roadway" [
      set is-road? true
    ] pt = "R-cycleway" [
      set is-bike? true
    ] pt = "R-footway" [
      set is-path? true
    ] pt = "R-railway" [
      set is-rail? true
    ] [
      set is-valid? false
  ])
]

  set pcolor ifelse-value (not is-valid?) [ red ] [
    ifelse-value is-path? [ brown + 2 ] [
      ifelse-value is-bike? [ violet + 2 ] [
        ifelse-value is-road? [ black + 2 ] [
          ifelse-value is-rail? [ grey ] [
            ifelse-value is-dwelling? [ pink + 2 ] [
              ifelse-value is-active? [ pink - 2 ] [
                ifelse-value is-serve? [ pink ] [
                  ifelse-value is-water? [ cyan - 1 ] [
                    ifelse-value is-greenspace? [ green + 2 ] [
                      ifelse-value is-in-borough? [ brown + 4 ] [ grey + 3 ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end


;{patches}
;{set default values for patches variables to avoid surprises}
to patches-init-variables
  set pcolor grey + 3
  set plabel-color black
  set patch-is-buildings-area? false
  set patch-is-road? false
  set patch-borough nobody
  set patch-centroid? false
  set patch-type []
  set patch-inside-map? false
  set patch-junctions []
end


;{world}
;{find the centroid of each borough and assign the corresponding borough name}
to patches-areas-find-borough-centroids [gis-data] ;{gis-boundaries}
  foreach gis:feature-list-of gis-data [ feature ->
    let center-point gis:location-of gis:centroid-of feature

    let the-borough-name "unknown"

    if is-stockholm? [
      set the-borough-name gis:property-value feature "Namn"
    ]
    if is-malmo? [
      set the-borough-name gis:property-value feature "DELOMR"
    ]

    let the-borough nobody
    ask patch (item 0 center-point) (item 1 center-point) [
      set patch-centroid? true
      sprout-boroughs 1 [
        set borough-name the-borough-name
        set the-borough self
        initialize-borough
      ]
    ]
    ask patches gis:intersecting feature [
      set patch-borough the-borough
      set pcolor brown + 4
    ]

  ]
end


;{world}
;{assign to each patch an area type (e.g. residential, commercial, etc.). It will allow the construction of many buildings to cover an entire area}
to patches-assign-area-features [gis-data a-patch-type]

  foreach gis:feature-list-of gis-data [ feature ->
    let b-subtype "undefined"

    let footprint patches gis:intersecting feature

    ask footprint [

      if a-patch-type = "from-file" [
        let area-kind gis:property-value feature "fclass"

        (ifelse (member? area-kind ["graveyard" "hospital" "kindergarten" "school" "fast_food" "sports_centre" "swimming_pool"]) [
          set a-patch-type "A-service"
        ] (member? area-kind ["park" "pitch" "playground"]) [
          set a-patch-type "A-pois-green"
        ] (member? area-kind ["reservoir" "water" "wetland"]) [
          set a-patch-type "A-pois-water"
        ] area-kind = "building" [
          let building-kind gis:property-value feature "type"
          (ifelse (member? building-kind ["apartments" "detached" "house" "residential" "terrace" "semi"]) [
            set a-patch-type "A-apartment"
          ] (member? building-kind ["commercial" "farm" "hotel" "industrial" "kiosk" "office" "restaurant" "retail" "service" "warehouse" "chapel" "church" "garage" "garages" "sports_hall" "manufacture" "greenhouse"]) [
            set a-patch-type "A-activity"
          ] [
            output-warning (word "\"building\" type \"" building-kind "\" not recognized -- ignoring it")
          ])
        ] [
          output-warning (word "fclass feature type \"" area-kind "\" not recognized -- ignoring it")
        ])
      ]

      if a-patch-type != "from-file" [
        set patch-type lput a-patch-type patch-type
      ]

      if a-patch-type = "A-apartment" or a-patch-type = "A-activity" [
        set patch-id gis:property-value feature "osm_id"
        set patch-subtype gis:property-value feature "type"
        set b-subtype patch-subtype
        set patch-is-buildings-area? true
      ]
      if a-patch-type = "A-pois-green" or a-patch-type = "A-pois-water" or a-patch-type = "A-service" [
        set patch-id gis:property-value feature "osm_id"
        set patch-subtype gis:property-value feature "fclass"
        if a-patch-type = "A-service" [
          set b-subtype patch-subtype
          set patch-is-buildings-area? true
        ]
      ]
    ]

    if a-patch-type = "A-apartment" or a-patch-type = "A-activity" or a-patch-type = "A-service" [
      let center-point gis:location-of gis:centroid-of feature

      create-buildings 1 [
        set building-type a-patch-type
        set building-footprint footprint
        set building-intervention-planned? false
        set building-scb-type "NA"
        set last-renovation 0
        set n-dwellings 0
        set building-subtype b-subtype
        set size 12
        set xcor item 0 center-point
        set ycor item 1 center-point
        (ifelse b-subtype = "apartments" [
          set shape "tower block"
          set size 18
          set color grey
          set building-scb-type "multi-dwelling buildings"
        ] b-subtype = "detached" [
          set shape "house two story"
          set size 12
          set color grey
          set building-scb-type "one- or two-dwelling buildings"
        ] b-subtype = "house" or b-subtype = "residential" [
          set shape "house"
          set size 6
          set color grey
          set building-scb-type "one- or two-dwelling buildings"
        ] b-subtype = "terrace" [
          set shape "house ranch"
          set size 6
          set color grey
          set building-scb-type "other buildings"
        ] b-subtype = "commercial" or b-subtype = "retail" or b-subtype = "service" or b-subtype = "restaurant" or b-subtype = "hotel" or b-subtype = "kiosk" [
          set shape "building store"
        ] b-subtype = "industrial" or b-subtype = "office" [
          set shape "factory"
          set size 24
          set color color - 2
        ] b-subtype = "warehouse" [
          set shape "container"
          set color color - 2
          set size 24
        ] b-subtype = "farm" [
          set shape "sheep"
          set color white - 2
        ] building-type = "A-service" [
          set shape "building institution"
          set color color + 3
          set size 12
        ] [
          output-warning (word "unknown building subtype \"" b-subtype "\"")
          set shape "square"
        ])
        if building-type = "A-apartment" [

          set building-year scb-sample-building-year ; Use new approach based on SCB data
        ]

      ]
    ]
  ]
end

;{patches}
;{match GIS roads with patches}
to patches-roads-assign-type [gis-data road-type]

  foreach gis:feature-list-of gis-data [ feature ->
    let path patches gis:intersecting feature

    ask path [
      let road-kind gis:property-value feature "fclass"
      let assigned-type road-type

      if road-type = "from-file" [
        (ifelse road-kind = "cycleway" [
          set assigned-type "R-cycleway"
        ] (member? road-kind ["footway" "pedestrian" "path" "steps" "living_street"]) [
          set assigned-type "R-footway"
        ] (road-kind = "rail" or road-kind = "tram") [
          set assigned-type "R-railway"
        ] (member? road-kind ["motorway" "motorway_link" "primary" "primary_link" "residential" "secondary" "secondary_link" "service" "tertiary" "tertiary_link" "track" "track_grade1" "track_grade2" "unclassified"]) [
          set patch-type lput "R-roadway" patch-type
        ] [
          output-warning (word "fclass property for line data \"" road-kind "\" not recognized -- ignoring it")
        ])
      ]

      set patch-type lput assigned-type patch-type
      set patch-is-road? assigned-type != "R-railway"
    ]
  ]

end

to find-junctions [road-type]
  if any? junctions with [junction-type = road-type] [
    output-error (word "Already created network for \"" road-type "\"")
  ]
  let network-patches patches with [member? road-type patch-type]
  ask network-patches with [not member? road-type patch-junctions] [
    ; the qualifier shouldn't really be necessary
    let n-network-neighbours count neighbors4 with [member? road-type patch-type]
    if n-network-neighbours = 1 or n-network-neighbours > 2 [
      ; these patches are endpoints (nbrs = 1) or junctions (nbrs = 3 or 4)
      set patch-junctions lput road-type patch-junctions
    ]
  ]
  ask network-patches with [member? road-type patch-junctions and count neighbors4 with [member? road-type patch-type] = 1 and count neighbors4 with [member? road-type patch-junctions] = 1] [
    ; these patches are endpoints and have a neighbour that is a junction
    ; we remove them as 'roads' of this type, assuming they are rasterization errors
    set patch-junctions remove road-type patch-junctions
    set patch-type remove road-type patch-type
  ]

  set network-patches patches with [member? road-type patch-type]
  ask network-patches with [member? road-type patch-junctions] [
    set patch-junctions remove road-type patch-junctions
  ]
  ask network-patches [
    let n-network-neighbours count neighbors4 with [member? road-type patch-type]
    if n-network-neighbours = 1 or n-network-neighbours > 2 [
      set patch-junctions lput road-type patch-junctions
      sprout-junctions 1 [
        set junction-type road-type
        set shape "circle"
        set color road-type-colour road-type
        set hidden? true
      ]
    ]
  ]

  output-note (word count junctions with [junction-type = road-type] " \"" road-type "\" junctions created")
end

to connect-road-network [road-type]
  find-junctions road-type

  if any? routes with [route-type = road-type] [
    output-error (word "Already created route for \"" road-type "\"")
  ]

  ask junctions with [junction-type = road-type] [

    let this-junction self

    ask neighbors4 with [member? road-type patch-type] [
      ; Moving away from this junction, find all the patches on the road until we get to the next junction

      let this-road-patches []
      set this-road-patches lput [patch-here] of this-junction this-road-patches

      let this-patch self

      while [ifelse-value (this-patch = nobody) [false] [not any? (junctions-on this-patch) with [junction-type = road-type]]] [
        set this-road-patches lput this-patch this-road-patches
        let next-patch [one-of neighbors4 with [member? road-type patch-type and not member? self this-road-patches]] of this-patch
        ; next-patch can be 'nobody' if, for example, the road goes round in a circle and ends up back at the junction
        set this-patch next-patch
      ]

      if this-patch != nobody [
        set this-road-patches lput this-patch this-road-patches
        let next-junction one-of (junctions-on this-patch) with [junction-type = road-type]
        set this-road-patches remove-duplicates this-road-patches

        ask this-junction [
          ifelse route-neighbor? next-junction [
            ask route-with next-junction [
              if length road-patches > length this-road-patches [
                set road-patches this-road-patches
              ]
            ]
          ] [
            create-route-with next-junction [
              set road-patches this-road-patches
              set route-type road-type
              set color road-type-colour road-type
              set hidden? true
            ]
          ]
        ]
      ]
    ]

  ]
  output-note (word count routes with [route-type = road-type] " \"" road-type "\" routes created")
  output-note (word count routes with [route-type = road-type and any? both-ends with [junction-type != road-type]] " having unequal junctions")
end

to-report road-type-colour [ road-type ]
  report ifelse-value (road-type = "R-roadway") [ black ] [
    ifelse-value (road-type = "R-cycleway") [ lime - 2 ] [
      ifelse-value (road-type = "R-footway") [ blue - 2 ] [
        ifelse-value (road-type = "R-railway") [ pink - 2 ] [
          red
        ]
      ]
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GO
;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  if error? [
    print-progress (word "error tick " ticks)
    tick
    stop
  ]

  print-progress (word "starting tick " ticks)

  update-date
  set n-crimes 0
  set n-hate-crimes 0
  set n-too-diverse 0
  set n-in-debt 0


  print-progress "updating temperature"
  set yesterday-temperature today-temperature
  env-set-today-temperature

  print-progress "restoring trust to baseline"
  ask households with [ abs (household-trust - household-baseline-trust) > 1e-8 ] [
    let diff household-baseline-trust - household-trust
    set household-trust household-trust + (trust-ret * diff)
  ]

  print-progress "decaying buildings"
  if (yesterday-temperature < 0 and today-temperature >= 0) or (yesterday-temperature >= 0 and today-temperature < 0) [
    ask one-of buildings with [building-type = "A-apartment"] [
      building-energy-efficiency-decay
    ]
  ]

  print-progress "implementing moves"
  set n-moved 0
  association-offer-houses

  print-progress "starting daily routine"
  ask households [
    households-create-todays-routine
  ]

  let ok? true
  let i 1
  while [ok?] [
    print-progress (word "visiting patches (" i ")")
    set ok? false
    ask households [
      if households-daily-routine [
        set ok? true
      ]
    ]
    ask households [
      households-accumulate-encounters
    ]
    set i i + 1
  ]

  print-progress "finishing daily routine"
  ask households [
    households-go-home
  ]

  print-progress "checking interventions to start"
  ask interventions with [ intervention-start = ticks ] [
    start-intervention
  ]

  print-progress "stepping interventions"
  ask interventions with [ intervention-active? ] [
    step-intervention
  ]

  print-progress "updating apartments"
  ask apartments [
    apartments-update-variables
  ]

  print-progress "updating buildings"
  ask buildings [
    buildings-update-variables
  ]

  print-progress "updating households"
  ask households [
    households-update-crime
  ]

  ; Manage internal economy at the end of the month
  if end-of-the-month? [
    print-progress "end of month updates"
    ask households [
      households-receive-wage
      households-pay-rent-and-bills
    ]
  ]

  ; Update unhappinesses

  print-progress "updating happiness"
  ask households [
    set household-finance household-finance - household-daily-expenses
    if household-finance < 0 [
      lt:fpush unhappiness-money ticks
      set n-in-debt n-in-debt + 1
      if networked-unhappiness? [
        ask social-tie-neighbors with [unhappy-money?] [
          lt:fpush unhappiness-money ticks
        ]
      ]
      set household-trust household-trust - (money-d-trust * household-trust)
    ]
    if household-n-encounters > 0 and household-n-same-encounters / household-n-encounters < household-homophily [
      lt:fpush unhappiness-heterophily ticks
      set n-too-diverse n-too-diverse + 1
      if networked-unhappiness? [
        ask social-tie-neighbors with [unhappy-heterophily?] [
          lt:fpush unhappiness-heterophily ticks
        ]
      ]
      set household-trust household-trust - (hetero-d-trust * household-trust)
    ]
    ; Crime and racism handled separately

    ; All unhappiness lists should have old items removed if enough time has elapsed since the most recent one

    if lt:length unhappiness-crime > 0 and ticks - lt:first unhappiness-crime >= household-forgiveness-crime [
      lt:filter [ t -> ticks - t <= household-forgetting-crime ] unhappiness-crime
    ]
    if lt:length unhappiness-money > 0 and ticks - lt:first unhappiness-money >= household-forgiveness-money [
      lt:filter [ t -> ticks - t <= household-forgetting-money ] unhappiness-money
    ]
    if lt:length unhappiness-heterophily > 0 and ticks - lt:first unhappiness-heterophily >= household-forgiveness-hetero [
      lt:filter [ t -> ticks - t <= household-forgetting-hetero ] unhappiness-heterophily
    ]
    if lt:length unhappiness-racism > 0 and ticks - lt:first unhappiness-racism >= household-forgiveness-racism [
      lt:filter [ t -> ticks - t <= household-forgetting-racism ] unhappiness-racism
    ]
  ]

  ; Apply to move if unhappy for long enough

  print-progress "applications to move"

  ask households [
    ifelse household-unhappy? [
      set consecutive-days-unhappy consecutive-days-unhappy + 1
      set days-unhappy days-unhappy + 1
    ] [
      set consecutive-days-unhappy 0
    ]

    let use-n-unhappy-move min (list n-unhappy-move max (list 10 ((floor (ticks / 2)) + 1)))
    if consecutive-days-unhappy >= use-n-unhappy-move and not lt:member? move-waiting-list self [
      households-apply-to-move
    ]

    ; update observation variables

    if unhappy-crime? [
      set days-unhappy-crime days-unhappy-crime + 1
    ]
    if unhappy-money? [
      set days-unhappy-money days-unhappy-money + 1
    ]
    if unhappy-heterophily? [
      set days-unhappy-hetero days-unhappy-hetero + 1
    ]
    if unhappy-racism? [
      set days-unhappy-racism days-unhappy-racism + 1
    ]
    if household-protesting? [
      set days-protesting days-protesting + 1
    ]
  ]


  if hh-file != "NA" and hh-file != "" and hh-file != 0 and hh-file-write-frequency > 0 and ticks mod hh-file-write-frequency = 0 [
    print-progress (word "saving households to \"" hh-file "\"")
    save-households hh-file
  ]


  tick

end

to-report n-hh-write-frequency-units
  report (ifelse-value (hh-file-freq-units = "days") [ ticks ]
    (hh-file-freq-units = "weeks") [ floor (ticks / 7) ]
    (hh-file-freq-units = "months") [ n-months ]
    (hh-file-freq-units = "years") [ n-years ] [ "PANIC" ])
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; HOUSEHOLDS
;;;;;;;;;;;;;;;;;;;;;;;;;
;{procedures associated with agents of type households}

;{households}
;{initialise households' variables}
to households-init-variables
  set hidden? true

  set household-borough borough-sample-by-flats

  ; Use SCB data to set household demographic, employment and tenancy attributes

  let hh-scb-type scb-sample-household-type
  let n-wage-earners scb-n-wage-from-hh-type hh-scb-type
  set household-size scb-hh-size-from-hh-type hh-scb-type
  set household-gender scb-gender-from-hh-type hh-scb-type

  let hh-dw-type scb-sample-household-dwelling-type hh-scb-type
  set household-floor-space scb-get-household-floor-space hh-scb-type hh-dw-type
  set household-tenancy scb-tenancy-type-from-dwelling-type hh-dw-type

  ; With the SCB data, find the household an apartment
  ; N.B. This may cause the household's borough and tenancy to change

  set household-apartment one-of household-suitable-apartments true true

  if household-apartment = nobody [
    output-error (word "Could not find an apartment for household " who " with SCB type " hh-scb-type ", SCB dwelling type " hh-dw-type ", floor space "
      household-floor-space " and tenancy " household-tenancy " in borough " ([borough-name] of household-borough))
  ]

  ask household-apartment [
    set apartment-occupied? true
    set apartment-household myself
  ]

  ; Set cultural background (native/non-native) based on borough stat

  ifelse (override-eth? and random-float 1 > p-eth-1) or (not override-eth? and random-float 1 <= ([data-foreign-born-p] of household-borough)) [
    set household-ethnicity 2 + random (n-ethnicities - 1)
    set household-reach eth-ge2-min-reach + random-float (eth-ge2-max-reach - eth-ge2-min-reach)
    set household-workplace-reach eth-ge2-work-reach
    set household-trust eth-ge2-min-trust + random-float (eth-ge2-max-trust - eth-ge2-min-trust)
  ] [
    set household-ethnicity 1
    set household-reach eth-1-min-reach + random-float (eth-1-max-reach - eth-1-min-reach)
    set household-workplace-reach eth-1-work-reach
    set household-trust eth-1-min-trust + random-float (eth-1-max-trust - eth-1-min-trust)
  ]

  ; Set other trust parameters

  set household-baseline-trust household-trust
  set household-tolerance trust-diff ; for now, everyone has the same tolerance, but by giving it an 'own' variable, we can more easily change that in future

  ; Find the household the appropriate number of jobs

  set household-employed? false
  let new-n-wage-earners 0
  repeat n-wage-earners [
    let new-household-employed? random-float 1 < ([data-employed-p] of household-borough)
    if new-household-employed? [
      set new-n-wage-earners new-n-wage-earners + 1
      set household-employed? (household-employed? or new-household-employed?)
    ]
  ]
  set n-wage-earners new-n-wage-earners

  ; Give a random workplace (an activity) to each of the household's wage earners to go during the day

  set household-activity n-values n-wage-earners [one-of activities]

  ; Use the number of actual wage-earners to calculate the income
  ifelse household-employed? [
    set household-income sum n-values n-wage-earners [[borough-random-income] of household-borough]
  ] [
    set household-income [data-benefits-kr] of household-borough
  ]
  ; Set initial finance available to household equal to 1 income
  set household-finance household-income
  set household-expenses scb-get-household-expenses hh-scb-type

  ; Set greenspace locations used

  set household-cycles? random-float 1 <= p-cycle
  set household-greenspace sort patches in-radius (ifelse-value household-cycles? [max-cycle] [max-walk]) with [member? "A-pois-green" patch-type]

  ; Set services used

  set household-services sort n-of n-services-per-hh services

  ; Set the habits for enviromental behaviour
  set household-habits-eco sample-range-dist-fp hh-init-eco-habits range-hh-init-eco

  set household-criminal? ifelse-value (random-float 1 < p-criminal) [ true ] [ false ]

  set household-homophily homophily-min + ifelse-value (homophily-max = homophily-min) [0] [random-float (homophily-max - homophily-min)]

  ; Initialize unhappinesses

  set unhappiness-racism lt:make
  set unhappiness-crime lt:make
  set unhappiness-money lt:make
  set unhappiness-heterophily lt:make

  set household-tolerance-crime sample-range-dist tolerance-crime range-crime
  set household-tolerance-money sample-range-dist tolerance-money range-money
  set household-tolerance-hetero sample-range-dist tolerance-hetero range-hetero
  set household-tolerance-racism sample-range-dist tolerance-racism range-racism
  set household-forgiveness-crime sample-range-dist forgiveness-crime range-crime
  set household-forgiveness-money sample-range-dist forgiveness-money range-money
  set household-forgiveness-hetero sample-range-dist forgiveness-hetero range-hetero
  set household-forgiveness-racism sample-range-dist forgiveness-racism range-racism
  set household-forgetting-crime sample-range-dist forgetting-crime range-crime
  set household-forgetting-money sample-range-dist forgetting-money range-money
  set household-forgetting-hetero sample-range-dist forgetting-hetero range-hetero
  set household-forgetting-racism sample-range-dist forgetting-racism range-racism

  set consecutive-days-unhappy 0

  set household-protesting? false
  set household-in-intervention? false

  ; Initialize hh observation variables
  set days-unhappy 0
  set days-unhappy-money 0
  set days-unhappy-racism 0
  set days-unhappy-crime 0
  set days-unhappy-hetero 0
  set days-protesting 0
  set n-move-requests 0
  set n-moves 0
end

to-report sample-range-dist [ dist-mean dist-p ]
  let diff dist-mean * random-float dist-p
  let dist-min dist-mean * (1 - (dist-p / 2))
  report round (dist-min + diff)
end

to-report sample-range-dist-fp [ dist-mean dist-p ]
  let diff dist-mean * random-float dist-p
  let dist-min dist-mean * (1 - (dist-p / 2))
  report (dist-min + diff)
end

to households-apply-to-move
  if not household-in-intervention? [
    lt:lpush move-waiting-list self
    set n-move-requests n-move-requests + 1
  ]
end

to association-offer-houses
  lt:filter [ hh -> [not household-in-intervention?] of hh ] move-waiting-list
  repeat moves-per-tick [
    if lt:length move-waiting-list > 0 [
      let request-hh lt:fpop move-waiting-list

      if not find-apartment-for-hh? request-hh options-per-move [
        lt:lpush move-waiting-list request-hh
      ]
    ]
  ]
end

to-report find-apartment-for-hh? [ hh tries ]
  let moved? false

  ask hh [
    let suitable-apartments household-suitable-apartments false true

    if count suitable-apartments > 0 [
      let offered-apartments shuffle sort n-of min (list tries (count suitable-apartments)) suitable-apartments
      while [ not moved? and length offered-apartments > 0 ] [
        if household-accept-apartment? first offered-apartments [
          move-household first offered-apartments
          set moved? true
        ]
        set offered-apartments but-first offered-apartments
      ]
    ]
  ]

  report moved?
end

; {households} household-suitable-apartments
;
; A suitable apartment is one with a floor-space that is close to the household's floor space
; and a matching tenancy and is not occupied

to-report household-suitable-apartments [ same-borough? allow-compromise-tenancy? ]
  let my-tenancy household-tenancy
  let my-borough household-borough
  let my-floor household-floor-space
  let available apartments with [ not apartment-occupied? and apartment-renovation-status != "on-going" and apartment-scb-tenancy = my-tenancy and abs (my-floor - apartment-size) <= max-floor-space-diff ]
  if same-borough? [
    set available available with [ apartment-borough = my-borough ]
    if count available = 0 [
      ; same-borough? is true during initialization, and we have to find them an apartment
      let borough-apartments apartments with [ apartment-borough = my-borough and not apartment-occupied? and apartment-renovation-status != "on-going" ]

      ; compromise on floor space first
      set available borough-apartments with [ apartment-scb-tenancy = my-tenancy ]

      if count available = 0 [
        ; then compromise on tenancy if allowed

        if allow-compromise-tenancy? [
          set available borough-apartments
        ]

        let compromise-tenancy? allow-compromise-tenancy?

        if count available = 0 [
          ; finally, compromise on borough
          set available household-suitable-apartments false allow-compromise-tenancy?

          if count available = 0 [
            ; compromise on floor space having not found any in any borough with matching floor space and tenancy
            set available apartments with [ not apartment-occupied? and apartment-renovation-status != "on-going" ]
            if count available = 0 [
              output-error "There are no apartments that are not occupied or being renovated; reduce the number of households or increase the number of apartments per building"
            ]
            if count available with [apartment-scb-tenancy = my-tenancy] != 0 [
              ; 'de-'compromise on tenancy

              set available available with [apartment-scb-tenancy = my-tenancy]
              set compromise-tenancy? false
            ]
          ]

          ; adjust the household's borough
          let burghs remove-duplicates [ apartment-borough ] of available
          set household-borough one-of burghs
          output-warning (word "Had to change borough of a household from " my-borough " to " household-borough " to find them an apartment" (ifelse-value compromise-tenancy? [ "; and will also need to adjust their tenancy" ] [ "" ]))
          set my-borough household-borough
          set available available with [ apartment-borough = my-borough ]
        ]

        if compromise-tenancy? [
          let tenancies remove-duplicates [ apartment-scb-tenancy ] of available
          set household-tenancy one-of tenancies
          output-warning (word "Had to change tenancy of a household from " my-tenancy " to " household-tenancy " to find them an apartment in " ([borough-name] of my-borough))
          set my-tenancy household-tenancy
          set available available with [ apartment-scb-tenancy = my-tenancy ]
        ]
      ]
    ]
  ]
  report available
end

to-report household-better-apartments
  let my-tenancy household-tenancy
  let my-borough household-borough
  let my-floor [apartment-size] of household-apartment
  let my-newness [apartment-newness] of household-apartment
  let selection apartments with [ not apartment-occupied? and apartment-renovation-status != "on-going" and apartment-borough = my-borough
    and apartment-scb-tenancy = my-tenancy and apartment-size > my-floor and apartment-newness > my-newness ]
  if count selection = 0 [
    ; start compromising on the criteria
    let brgh-apt apartments with [ not apartment-occupied? and apartment-renovation-status != "on-going" and apartment-borough = my-borough ]
    if count selection = 0 [
      set brgh-apt apartments with [ not apartment-occupied? and apartment-renovation-status != "on-going" ]
      if count selection = 0 [
        output-error ("No spare apartments to move a household into during renovation. Increase the number of apartments.")
      ]

    ]
    ; try to match tenancy
    set selection brgh-apt with [ apartment-scb-tenancy = my-tenancy ]

    ifelse count selection = 0 [
      set selection brgh-apt
    ] [
      ; try to match floor space
      if count selection with [ apartment-size > my-floor ] > 0 [
        set selection selection with [ apartment-size > my-floor ]
      ]
    ]
  ]
  report selection
end

to-report household-accept-apartment? [ an-apartment ]
  let accept? true
  if unhappy-crime? and [[ borough-n-crimes ] of apartment-borough ] of an-apartment > [ borough-n-crimes ] of household-borough [
    set accept? false
  ]
  if unhappy-money? and [ apartment-rent ] of an-apartment > [ apartment-rent ] of household-apartment [
    set accept? false
  ]
  ; should do something with unhappy-racism? and unhappy-heterophily?
  report accept?
end

to-report household-flashpoint?
  report unhappy-crime? and unhappy-money? and ((unhappy-racism? and household-ethnicity > 1) or (unhappy-heterophily? and household-ethnicity = 1))
end

to-report household-unhappy?
  report unhappy-crime? or unhappy-money? or ((unhappy-racism? and household-ethnicity > 1) or (unhappy-heterophily? and household-ethnicity = 1))
end

to move-household [ an-apartment ]
  if [apartment-occupied?] of an-apartment [
    output-error "Attempt to move a household to an occupied apartment"
  ]
  ask household-apartment [
    set apartment-household nobody
    set apartment-occupied? false
  ]
  ask an-apartment [
    set apartment-household myself
    set apartment-occupied? true
  ]
  set household-apartment an-apartment
  set household-borough [ apartment-borough ] of an-apartment
  households-create-routine
  move-to an-apartment
  set n-moved n-moved + 1

  if not household-in-intervention? [
    ; Reset unhappiness to give the move a chance...
    set unhappiness-racism lt:make
    set unhappiness-crime lt:make
    set unhappiness-money lt:make
    set unhappiness-heterophily lt:make
  ]

  set n-moves n-moves + 1
end

; {households} households-create-routine
;
; This procedure sets the household's 'routine' -- a set of patches visited including footpaths and cycleways en route

to households-create-routine
  let my-home [patch-here] of household-apartment
  let my-locations []
  foreach household-greenspace [ gs-patch ->
    if [count neighbors with [ patch-is-road? ]] of gs-patch > 0 [
      set my-locations lput gs-patch my-locations
    ]
  ]
  set my-locations (sentence my-locations map [ x -> [patch-here] of x ] household-activity)
  set my-locations (sentence my-locations [[patch-here] of household-apartment] of social-tie-neighbors)
  set my-locations (sentence my-locations map [ x -> [patch-here] of x ] household-services)

  ifelse routines-include-routes? [
    set household-routine (sentence my-locations (households-find-routes my-home max-walk "R-footway" my-locations)
      (ifelse-value household-cycles? [households-find-routes my-home max-cycle "R-cycleway" my-locations] [ [] ]))
  ] [
    set household-routine my-locations
  ]
end


; {households} households-find-routes

to-report households-find-routes [ my-home max-dist road-type my-locations ]

  let accessible-roads [ patches in-radius max-dist with [ member? road-type patch-type ] ] of my-home

  let starts accessible-roads with-min [distance my-home]
  let ends accessible-roads with [ member? self my-locations or any? neighbors with [ member? self my-locations ] ]

  if not any? starts or not any? ends [
    report []
  ]

  let useful-routes []

  ask starts [
    ask ends [
      set useful-routes (sentence useful-routes route-from-to myself self road-type max-dist)
    ]
  ]

  report remove-duplicates useful-routes
end

to-report route-from-to [ start finish road-type max-dist ]

  if is-number? route-table [
    set route-table table:make
  ]

  let table-key route-key start finish road-type

  if table:has-key? route-table table-key [
    report table:get route-table table-key
  ]

  let start-routes routes with [ route-type = road-type and member? start road-patches ]
  let end-routes routes with [ route-type = road-type and member? finish road-patches ]

  let min-route []

  ask start-routes [
    let i position start road-patches
    let rp-start road-patches

    ask both-ends [
      let the-route ifelse-value (patch-here = first rp-start) [ reverse sublist rp-start 0 (i + 1) ] [ sublist rp-start i length rp-start ]
      let j-start self

      ask end-routes [
        let j position finish road-patches
        let rp-end road-patches

        ask both-ends [
          let j-route dijkstra j-start self max-dist road-type

          if length j-route != 0 [
            let new-route (sentence the-route j-route ifelse-value (patch-here = first rp-end) [ sublist rp-end 0 (j + 1) ] [ reverse sublist rp-end j length rp-end ])

            if (length min-route = 0 or length min-route > length new-route) and length new-route <= max-dist [
              set min-route new-route
            ]
          ]
        ]
      ]
    ]
  ]

  table:put route-table table-key min-route
  report min-route
end

to-report dijkstra [ start-junction finish-junction max-dist road-type ]
  let road-junctions junctions with [junction-type = road-type]

  ask road-junctions [
    set dijkstra-visited? false
    set dijkstra-distance ifelse-value (self = start-junction) [0] [world-width * world-height + 1] ; 'infinity'
    set dijkstra-previous nobody
  ]

  let unvisited-nodes road-junctions
  let current-node start-junction

  while [ any? unvisited-nodes ] [

    ask current-node [
      let me who
      let d dijkstra-distance

      ask route-neighbors with [not dijkstra-visited?] [
        let dd d + length ([ road-patches ] of route me who)

        if dd <= max-dist and dd < dijkstra-distance [
          set dijkstra-distance dd
          set dijkstra-previous current-node
        ]

      ]

      set dijkstra-visited? true
    ]

    set unvisited-nodes unvisited-nodes with [not dijkstra-visited? and dijkstra-previous != nobody]

    set current-node ifelse-value (any? unvisited-nodes) [one-of unvisited-nodes with-min [dijkstra-distance]] [nobody]
  ]

  ifelse current-node = nobody [
    report []
  ] [
    let patch-list []
    set current-node finish-junction
    while [ current-node != start-junction ] [
      ask current-node [
        let prev-who [who] of dijkstra-previous
        set patch-list (sentence ([road-patches] of route prev-who who) patch-list)
        set current-node dijkstra-previous
      ]
    ]
    report patch-list
  ]
end

to-report route-key [ start finish road-type ]
  report (word road-type ":" [pxcor] of start ":" [pycor] of start ":" [pxcor] of finish ":" [pycor] of finish)
end

;{households}
;{create connections with other households}
;{social circles model by Hamill and Gilbert (2009) for local ties + random wires for global ties}
to households-create-network
  ; Use the social circles algorithm to create connections with other households based on local neighbourhood
  ; and shared ethnicity
  ask households [
    move-to household-apartment
    set heading random 360
    fd random-float circles-max-move
  ]
  ask households [
    let my-ethnicity household-ethnicity
    ifelse household-homophily = 0 [
      create-social-ties-with households in-radius household-reach with [distance myself < household-reach and household-ethnicity != my-ethnicity]
    ] [
      create-social-ties-with other households in-radius household-reach with [distance myself < household-reach and household-ethnicity = my-ethnicity]
      let n count social-tie-neighbors
      let max-n ceiling ((n / household-homophily) - n)
      if max-n > 0 [
        let possible-connections households in-radius household-reach with [distance myself < household-reach and household-ethnicity != my-ethnicity]
        ifelse count possible-connections > max-n [
          create-social-ties-with n-of max-n possible-connections
        ] [
          if count possible-connections > 0 [
            create-social-ties-with possible-connections
          ]
        ]
      ]
    ]
  ]
  ; Use the social circles algorithm to create connections with other household based on workplace
  ; ethnicity is (perhaps wrongly) assumed not to be a factor here
  ask households with [household-employed?] [
    move-to one-of household-activity
    set heading random 360
    fd random-float circles-max-move-work
  ]
  ask households with [household-employed?] [
    create-social-ties-with other (households with [household-employed?]) in-radius household-workplace-reach with [distance myself < household-workplace-reach]
  ]

  ask social-ties [
    set hidden? true
  ]

  ask households [
    move-to household-apartment
  ]
end

;{households}
;{households pay the rent to the housing association}
to households-pay-rent-and-bills
  let rent-to-pay 0
  let bills-to-pay 0
  ask household-apartment [
    set rent-to-pay round apartment-rent
    set bills-to-pay round apartment-energy-bill
    set apartment-energy-bill 0
  ]
  ; Pay rent and bills
  set household-finance (household-finance - rent-to-pay)
  set household-finance (household-finance - bills-to-pay)
  ; Transfer the rent to the household association finance
  set ha-finance (ha-finance + rent-to-pay)
end

to-report household-daily-expenses
  report round ((12 / (ifelse-value (HBS-year = 2008) [366] [365])) * ((first household-expenses) - ((last household-expenses) / 2) + ifelse-value (household-finance < 0) [0] [random-float (last household-expenses)]))
end

;{households}
;{households receive monthly wage}
to households-receive-wage
  set household-finance household-finance + household-income
end

to households-create-todays-routine
  set household-todays-routine (list household-apartment)
  if household-employed? [
    set household-todays-routine lput (one-of household-activity) household-todays-routine
  ]
  set household-todays-routine lput (one-of household-services) household-todays-routine
  set household-todays-routine shuffle sentence household-todays-routine n-of (min (list n-daily-visits (length household-routine))) household-routine
  set household-n-encounters 0
  set household-n-same-encounters 0
end

;{households}
;{households move to work, services, or green areas}
to-report households-daily-routine
  if length household-todays-routine > 0 [
    move-to first household-todays-routine
    set household-todays-routine but-first household-todays-routine
  ]
  report length household-todays-routine > 0
end

to households-accumulate-encounters
  let my-ethnicity household-ethnicity
  let ethnicities-here [household-ethnicity] of households-here
  let here-n-encounters (length ethnicities-here) - 1
  let here-n-same-encounters (length filter [ eth -> eth = my-ethnicity ] ethnicities-here) - 1
  let max-ethnicities modes ethnicities-here

  set household-n-encounters household-n-encounters + here-n-encounters
  set household-n-same-encounters household-n-same-encounters + here-n-same-encounters

  if (here-n-encounters > 0                                                  ; IF there's at least 1 other person here ...
    and here-n-same-encounters < here-n-encounters                           ; ... with a different ethnicity ...
    and here-n-same-encounters / here-n-encounters < household-homophily     ; ... and there aren't enough others here with the same ethnicity for my liking ...
    and (member? my-ethnicity max-ethnicities or my-ethnicity = 1)           ; ... and my ethnicity is one of the majority ethnicities here or I have the 'dominant' ethnicity ...
    and unhappy-heterophily?) [                                              ; ... and I'm not happy about the number of people I keep meeting with different ethnicity

    ask one-of households-here with [household-ethnicity != my-ethnicity] [  ; THEN pick someone to give some kind of racism-related unhappiness to
      lt:fpush unhappiness-racism ticks
      if networked-unhappiness? [
        ask social-tie-neighbors with [unhappy-racism?] [
          lt:fpush unhappiness-racism ticks
        ]
      ]
      set household-trust household-trust - (racism-d-trust * household-trust)
    ]
  ]

  let friends-here households-here with [member? myself social-tie-neighbors]
  if any? friends-here [
    let mean-trust mean [ household-trust ] of friends-here
    ; move my trust towards the mean
    let d-trust mean-trust - household-trust
    if abs d-trust <= household-tolerance [
      set household-trust household-trust + (visit-d-trust * d-trust)
    ]
  ]
end

;{households}
;{households return to their home}
to households-go-home
  move-to household-apartment
end

; {households} households-update-crime
;
; Update the last time the household experienced a crime, and if they are a criminal household,
; commit a crime on a randomly chosen other housheold with p-crime probability. The victim
; loses some money as a result of the crime (crime-cost parameter); the perpetrator gains
; (crime-benefit). These crimes are robberies, and assumed to be at home.

to households-update-crime
  if household-criminal? and random-float 1 < p-crime [
    let victim one-of other households
    ask victim [
      lt:fpush unhappiness-crime ticks
      set household-finance (household-finance - crime-cost)
      ask household-borough [
        set borough-n-crimes borough-n-crimes + 1
      ]
      if networked-unhappiness? [
        ask social-tie-neighbors with [unhappy-crime?] [
          lt:fpush unhappiness-crime ticks
        ]
      ]
      set household-trust household-trust - (crime-d-trust * household-trust)
    ]
    set household-finance (household-finance + crime-benefit)
  ]
end

to-report unhappy-crime?
  report lt:length unhappiness-crime >= household-tolerance-crime
end

to-report unhappy-money?
  report lt:length unhappiness-money >= household-tolerance-money
end

to-report unhappy-heterophily?
  report lt:length unhappiness-heterophily >= household-tolerance-hetero
end

to-report unhappy-racism?
  report lt:length unhappiness-racism >= household-tolerance-racism
end

to household-receive-notification [notification languages]
  let money-worse? true
  let crime-worse? true
  let racism-worse? true
  let hetero-worse? true
  if member? "money" notification and member? household-ethnicity languages and random-float 1 < household-trust [
    set money-worse? false
  ]
  if member? "crime" notification and member? household-ethnicity languages and random-float 1 < household-trust [
    set crime-worse? false
  ]
  if member? "racism" notification and member? household-ethnicity languages and random-float 1 < household-trust [
    set racism-worse? false
  ]
  if member? "hetero" notification and member? household-ethnicity languages and random-float 1 < household-trust [
    set hetero-worse? false
  ]
  if household-flashpoint? and (money-worse? or crime-worse? or racism-worse? or hetero-worse?) [
    household-suggest-protest
  ]
end

to-report household-choose-upgrade-option [ option-list ]
  let option random length option-list
  if unhappy-money? [
    set option position (min option-list) option-list
  ]
  if length option-list > 1 and (not unhappy-money? or min option-list < 1) [
    set household-trust household-trust + ((1 - household-trust) * mtg-d-trust)
  ]
  report option
end

to household-eco-education [ eco-change ]
  set household-habits-eco household-habits-eco * eco-change
  if household-habits-eco < min-eco-habits [
    set household-habits-eco min-eco-habits
  ]
  set household-trust household-trust + ((1 - household-trust) * mtg-d-trust)
end

to household-suggest-protest
  let n-friends-flash count social-tie-neighbors with [household-flashpoint?]
  let n-neighbours-flash count ([building-residents] of ([apartment-building] of household-apartment)) with [household-flashpoint?]
  if n-friends-flash + n-neighbours-flash > ifelse-value (household-ethnicity = 1) [ eth-1-protest-min ] [ eth-ge2-protest-min ] [
    ask social-tie-neighbors [
      household-confirm-protest
    ]
    ask [building-residents] of ([apartment-building] of household-apartment) [
      household-confirm-protest
    ]
    set household-protesting? true
  ]
end

to household-confirm-protest
  if household-flashpoint? [
    set household-protesting? true
  ]
end

to household-attend-meeting
  set household-protesting? false
  set household-trust household-trust + ((1 - household-trust) * mtg-d-trust)
end


to save-households [ file-name ]
  if behaviorspace-run-number != 0 [
    set file-name (word (substring file-name 0 ((length file-name) - 4)) "-" behaviorspace-run-number (substring file-name ((length file-name) - 4) (length file-name)))
  ]
  let exists? file-exists? file-name
  file-open file-name
  if not exists? [
    file-print csv:to-string [ ["id" "time" "borough" "building" "energy" "rent" "floorspace" "employed" "income" "finance" "efficiency" "gender" "size" "ethnicity" "homophily" "trust" "tenancy" "requests" "moves" "unhappy" "money" "racism" "heterophily" "crime" "protesting"] ]
  ]
  ask households [
    file-print csv:to-string (list (list who ticks ([borough-name] of household-borough) ([building-scb-type] of ([apartment-building] of household-apartment))
      ([apartment-energy-consumption] of household-apartment) ([apartment-rent] of household-apartment) ([apartment-size] of household-apartment)
      household-employed? household-income household-finance household-habits-eco household-gender household-size household-ethnicity
      household-homophily household-trust household-tenancy n-move-requests n-moves days-unhappy days-unhappy-money days-unhappy-racism days-unhappy-hetero
      days-unhappy-crime days-protesting))
  ]
  file-close
end


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; INTERVENTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;
;{procedures associated with the interventions that can be tested in the virtual environment}


to read-interventions [ file-name ]
  let iv-data csv:from-file file-name
  let iv-header first iv-data
  set iv-data but-first iv-data
  foreach iv-data [ iv ->
    create-interventions 1 [
      set intervention-active? false
      set intervention-stage "unimplemented"
      set intervention-notification-information []
      set intervention-notification-languages [1]
      set intervention-rent-change-options []
      set intervention-borough "all"
      set intervention-min-building-year 1800
      set intervention-max-building-year 2020
      set intervention-min-n-dwellings 0

      (foreach iv-header iv [ [ key value ] ->
        (ifelse key = "start" [
          ifelse item 0 value = "y" [
            let iv-ystart read-from-string substring value 1 5
            let iv-mstart ifelse-value item 5 value = "m" [ read-from-string substring value 6 8 ] [ 1 ]
            set intervention-start ticks-to-date iv-ystart iv-mstart 1
          ] [
            set intervention-start value
          ]
        ] key = "duration" [
          ifelse is-string? value [
            ifelse value = "random" [
              set intervention-duration iv-min-dur + random (1 + iv-max-dur - iv-min-dur)
            ] [
              output-error (word "Invalid value \"" value "\" for intervention duration (column \"duration\") in intervention-file \"" file-name "\"")
            ]
          ] [
            set intervention-duration value
          ]
        ] (key = "crime" or key = "money" or key = "hetero" or key = "racism") [
          ifelse value = "true" or value = true [
            set intervention-notification-information lput key intervention-notification-information
          ] [
            if value != "false" and value != false [
              output-error (word "Invalid value \"" value "\" for intervention-notification-information \"" key "\" in intervention-file \"" file-name "\" -- must be \"true\" or \"false\"")
            ]
          ]
        ] key = "lang" [
          (ifelse value = "all" [
            foreach n-values (n-ethnicities - 1) [ i -> i + 2 ] [ lang ->
              set intervention-notification-languages lput lang intervention-notification-languages
            ]
          ] value = "eth-1" [
            ; do nothing -- notification languages already includes 1
          ] [
            foreach first (csv:from-string value "|") [ lang ->
              set intervention-notification-languages lput lang intervention-notification-languages
            ]
          ])
        ] key = "rent" [
          ifelse is-string? value [
            foreach first (csv:from-string value "|") [ rent ->
              set intervention-rent-change-options lput rent intervention-rent-change-options
            ]
          ] [
            set intervention-rent-change-options lput value intervention-rent-change-options
          ]
        ] key = "energy" [
          (ifelse value = "iv-nrg-min" [
            set intervention-energy-efficiency-change iv-nrg-min
          ] value = "iv-nrg-max" [
            set intervention-energy-efficiency-change iv-nrg-max
          ] value = "random" [
            set intervention-energy-efficiency-change iv-nrg-min + random-float (iv-nrg-max - iv-nrg-min)
          ] is-number? value [
            set intervention-energy-efficiency-change value
          ] [
            output-error (word "Invalid value \"" value "\" for \"energy\" column in intervention-file \"" file-name "\"")
          ])
        ] key = "habits" [
          (ifelse value = "random" [
            set intervention-household-eco-habits-change 1 - (random-float iv-habit-max)
          ] value = "iv-habit-max" [
            set intervention-household-eco-habits-change iv-habit-max
          ] is-number? value [
            set intervention-household-eco-habits-change value
          ] [
            output-error (word "Invalid value \"" value "\" for \"habits\" column in intervention-file \"" file-name "\"")
          ])
        ] key = "meetings" [
          (ifelse value = "random" [
            set intervention-meetings random-poisson iv-mtg-mean
          ] value = "iv-mtg-mean" [
            set intervention-meetings iv-mtg-mean
          ] is-number? value [
            set intervention-meetings value
          ] [
            output-error (word "Invalid value \"" value "\" for \"meetings\" column in intervention-file \"" file-name "\"")
          ])
        ] key = "borough" [
          ifelse value = "random" [
            set intervention-borough [borough-name] of one-of boroughs
          ] [
            set intervention-borough value
          ]
        ] key = "built" [
          ifelse is-string? value [
            let minmax first (csv:from-string value "|")
            set intervention-min-building-year item 0 minmax
            set intervention-max-building-year item 1 minmax
          ] [
            set intervention-max-building-year value
          ]
        ] key = "size" [
          set intervention-min-n-dwellings value
        ] [
          output-error (word "Unrecognized column heading \"" key "\" in intervention file \"" file-name "\"")
        ])

      ])
      let burgh intervention-borough
      let min-built intervention-min-building-year
      let max-built intervention-max-building-year
      let min-size intervention-min-n-dwellings
      set intervention-buildings buildings with [ (burgh = "all" or (building-borough != nobody and burgh = [borough-name] of building-borough))
        and (many-iv-p-bldg? or not building-intervention-planned?)
        and building-type = "A-apartment" and building-year >= min-built and building-year <= max-built and n-dwellings >= min-size ]
      ask intervention-buildings [
        set building-intervention-planned? true
      ]
      output-print (word "Intervention " who " has " (count intervention-buildings) " buildings")
    ]
  ]
  ask interventions with [(count intervention-buildings) = 0] [
    output-warning (word "Intervention " who " found no apartment buildings "
      (ifelse-value intervention-borough = "all" [ "in any borough" ] [ (word "in borough \"" intervention-borough "\"") ])
      " " (ifelse-value many-iv-p-bldg? [ "with" ] [ "that were not already in an intervention and had" ])
      " building-year in [" intervention-min-building-year ", " intervention-max-building-year
      "], and at least " intervention-min-n-dwellings " dwellings" )
    die
  ]
end

to save-interventions [ file-name ]
  file-open file-name
  file-print csv:to-string [ [ "start" "duration" "crime" "money" "hetero" "racism" "lang" "rent" "energy" "habits" "meetings" "borough" "built" "size" ] ]
  ask interventions [
    let rent reduce [ [ so-far next ] -> (word so-far "|" next) ] intervention-rent-change-options
    let lang reduce [ [ so-far next ] -> (word so-far "|" next) ] intervention-notification-languages
    file-print csv:to-string (list (list intervention-start intervention-duration (member? "crime" intervention-notification-information)
      (member? "money" intervention-notification-information) (member? "hetero" intervention-notification-information)
      (member? "racism" intervention-notification-information) lang rent intervention-energy-efficiency-change
      intervention-household-eco-habits-change intervention-meetings intervention-borough
      (word intervention-min-building-year "|" intervention-max-building-year) intervention-min-n-dwellings))
  ]
  file-close
end

to random-intervention
  create-interventions 1 [
    set intervention-active? false
    set intervention-stage "unimplemented"
    set intervention-notification-information []
    set intervention-notification-languages [1]
    set intervention-rent-change-options []
    set intervention-start iv-min-start + random (365 * 5)
    set intervention-duration iv-min-dur + random (1 + iv-max-dur - iv-min-dur)
    foreach n-values (1 + random-poisson iv-opt-mean) [ (iv-rent-min + random-float (iv-rent-max - iv-rent-min)) ] [ rent ->
      set intervention-rent-change-options lput rent intervention-rent-change-options
    ]

    foreach n-values random iv-lang-max [ i -> i + 2 ] [ lang ->
      set intervention-notification-languages lput lang intervention-notification-languages
    ]

    set intervention-energy-efficiency-change iv-nrg-min + random-float (iv-nrg-max - iv-nrg-min)

    set intervention-meetings random-poisson iv-mtg-mean

    if random-float 1 < p-iv-habit [
      set intervention-household-eco-habits-change 1 - (random-float iv-habit-max)
    ]

    if random-float 1 < p-iv-crime [
      set intervention-notification-information lput "crime" intervention-notification-information
    ]
    if random-float 1 < p-iv-money [
      set intervention-notification-information lput "money" intervention-notification-information
    ]
    if random-float 1 < p-iv-hetero [
      set intervention-notification-information lput "hetero" intervention-notification-information
    ]
    if random-float 1 < p-iv-racism [
      set intervention-notification-information lput "racism" intervention-notification-information
    ]

    let burgh one-of boroughs
    set intervention-borough [borough-name] of burgh
    let iv-buildings buildings with [ building-borough = burgh and building-type = "A-apartment" and count building-residents > 0 and (many-iv-p-bldg? or not building-intervention-planned?) ]
    ifelse iv-n-buildings >= count iv-buildings [
      set intervention-buildings n-of (1 + random (count iv-buildings)) iv-buildings
    ] [
      set intervention-buildings n-of (1 + random iv-n-buildings) iv-buildings
    ]
    ask intervention-buildings [
      set building-intervention-planned? true
    ]
    set intervention-min-building-year min [building-year] of intervention-buildings
    set intervention-max-building-year max [building-year] of intervention-buildings
    set intervention-min-n-dwellings min [n-dwellings] of intervention-buildings
  ]
end

to-report intervention-households
  let result 0
  ask intervention-buildings [
    ifelse is-agentset? result [
      set result (turtle-set result building-residents)
    ] [
      set result building-residents
    ]
  ]
  report result
end

to start-intervention
  set intervention-active? true
  set intervention-stage "start"
  set intervention-building-progress []
end

to step-intervention
  (ifelse (intervention-stage = "start") [
    ask intervention-households [
      set household-in-intervention? true
    ]
    ask intervention-buildings [
      ask building-apartments [
        set apartment-renovation-status "on-going"
        set apartment-renovation-time -1
        set apartment-renovated? false
      ]
    ]

    set intervention-stage "meeting"
  ] (intervention-stage = "meeting") [
    ifelse intervention-meetings > 0 [
      ifelse length intervention-building-progress = 0 [
        set intervention-building-progress shuffle sort intervention-buildings
      ] [
        let the-building first intervention-building-progress
        intervention-hold-meeting the-building
        set intervention-building-progress but-first intervention-building-progress
        if length intervention-building-progress = 0 [
          set intervention-meetings intervention-meetings - 1
        ]
      ]
    ] [
      set intervention-stage "education"
      set intervention-building-progress shuffle sort intervention-buildings
    ]
  ] (intervention-stage = "education") [
    ifelse intervention-household-eco-habits-change = 1 or length intervention-building-progress = 0 [
      set intervention-building-progress []
      set intervention-stage "notification"
    ] [
      let the-building first intervention-building-progress
      intervention-educate-households the-building
      set intervention-building-progress but-first intervention-building-progress
    ]
  ] (intervention-stage = "notification") [
    intervention-notify-households
    ; A future version of the model could act on protesting households here
    ; e.g. by holding meetings
    ifelse any? intervention-households with [household-protesting?] [
      set intervention-meetings 1
      set intervention-stage "meeting"
    ] [
      set intervention-stage "negotiate"
    ]
  ] (intervention-stage = "negotiate") [
    intervention-negotiate-upgrade
    set intervention-stage "move-out"
  ] (intervention-stage = "move-out") [
    intervention-move-households-out
    set intervention-stage "renovation"
  ] (intervention-stage = "renovation") [
    intervention-renovate-buildings
    set intervention-stage "implementation"
  ] (intervention-stage = "implementation") [
    let apt intervention-apartments
    if all? apt [ apartment-renovated? ] [
      let d-eff intervention-energy-efficiency-change
      ask apt [
        set apartment-energy-efficiency apartment-energy-efficiency * d-eff
      ]
      set intervention-stage "move-in"
    ]
  ] (intervention-stage = "move-in") [
    intervention-move-households-in
    set intervention-stage "finished"
  ] (intervention-stage = "finished") [
    ask intervention-households [
      set household-in-intervention? false
    ]
    set intervention-active? false
  ] [
    output-error (word "Unrecognized intervention-stage: \"" intervention-stage "\"")
  ])
end

to intervention-notify-households
  let info intervention-notification-information
  let lang intervention-notification-languages
  ask intervention-households [
    household-receive-notification info lang
  ]
end

to intervention-negotiate-upgrade
  let upgrade-choices []
  let rent intervention-rent-change-options
  ask intervention-buildings [
    let upgrade-choice building-upgrade-choice rent
    set upgrade-choices lput (list self upgrade-choice) upgrade-choices
  ]
  set intervention-upgrade-choices upgrade-choices
end

to intervention-hold-meeting [ the-building ]
  ask the-building [
    ask building-residents [
      household-attend-meeting
    ]
  ]
end

to intervention-move-households-out
  let hh-loc []
  ask intervention-households [
    set hh-loc lput (list self household-apartment) hh-loc
    let new-apt intervention-find-temporary-apartment
    let old-apt household-apartment
    move-household new-apt
    ask old-apt [
      set apartment-occupied? true
    ]
  ]
  set intervention-hh-apartments hh-loc
end

to intervention-renovate-buildings
  let duration intervention-duration
  ask intervention-buildings [
    renovate-building duration
  ]
end

to intervention-educate-households [the-building]
  let eco-change intervention-energy-efficiency-change
  ask intervention-households [
    household-eco-education eco-change
  ]
end

to intervention-move-households-in
  foreach intervention-upgrade-choices [ upgrade-choice ->
    let the-building item 0 upgrade-choice
    let the-upgrade item 1 upgrade-choice
    let rent-factor item the-upgrade intervention-rent-change-options

    ask the-building [
      ask building-apartments [
        set apartment-rent apartment-rent * rent-factor
      ]
    ]
  ]

  foreach intervention-hh-apartments [ hh-loc ->
    let the-household item 0 hh-loc
    let the-apartment item 1 hh-loc

    ask the-household [
      ask the-apartment [
        set apartment-occupied? false
      ]
      move-household the-apartment
      set household-protesting? false
    ]
  ]
end

; {household} intervention-find-temporary-apartment
;
; Find a suitable apartment for the household while renovation of their apartment is on-going

to-report intervention-find-temporary-apartment
  let candidate-apartments household-better-apartments

  if count candidate-apartments = 0 [
    output-error "Not found a temporary apartment for a household to move in to"
  ]

  report one-of candidate-apartments with-min [ apartment-rent ]
end

to-report intervention-apartments
  let my-buildings intervention-buildings
  report apartments with [member? apartment-building my-buildings]
end

to renovate-building [renovation-time]
  let apartments-under-renovation apartments with [apartment-building = myself]
  let n-apartments count apartments-under-renovation
  if n-apartments > 0 [
    ask apartments-under-renovation [
      apartments-renovation-starts renovation-time
    ]
  ]
  set color orange
  output-print (word n-apartments " apartments started renovation in building " who)
  set last-renovation ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BUILDINGS
;;;;;;;;;;;;;;;;;;;;;;;;;
;{procedures associated with the creation and management of the agents: apartments, activities, and services}

;{apartments}
;{initialise apartments' variables}
to apartments-init-variables [a-building]
  ;;; Apartment's appareance ;;;s
  set hidden? true
  move-to a-building
  ask a-building [
    set n-dwellings n-dwellings + 1
  ]
  set shape "circle"
  ;;; Basic apartment's info ;;;

  set apartment-building a-building

  set apartment-size scb-sample-building-floor ; sample floor space of building from SCB data
  set apartment-scb-tenancy scb-sample-building-tenancy ; sample tenancy of building from SCB data
  set apartment-occupied? false
  set apartment-household nobody

  set apartment-energy-efficiency 1
  set apartment-energy-efficiency-decay-rate en-eff-decay + ((start-year - apartment-year) * en-eff-dk-p-yr)
  set apartment-rent floor (apartment-size * rent-per-m2)
  ;;; Renovation ;;;
  set apartment-renovated? false
  set apartment-renovation-time -1 ; if renovation-status is "on-going" then a negative number means the actual renovation hasn't started
  set apartment-renovation-status "not renovated"
  set apartment-newness apartment-year
  set apartment-energy-bill 0
  ; Call the update procedure since the beginning to avoid duplicates and mismatches
  apartments-update-variables
end

to-report apartment-year
  report [building-year] of apartment-building
end

to-report apartment-borough
  report [patch-borough] of patch-here
end

to-report building-borough
  report [patch-borough] of patch-here
end

;{apartments}
;{updated apartment's variables to reflect changes (e.g. renovation) during the time step}
to apartments-update-variables
  if (apartment-renovation-status = "on-going") [
    if  apartment-renovation-time > 0 [
      set apartment-renovation-time (apartment-renovation-time - 1)
    ]
    if (apartment-renovation-time = 0) [
      apartments-renovation-ends
    ]
  ]
  ; Take into account household environmental energy consumption habits (unless during the setup of the model)

  let apartment-usage-efficiency apartment-energy-efficiency
  if apartment-occupied? and apartment-household != nobody [ ; it can be nobody if we're in the middle of a renovation
    set apartment-usage-efficiency apartment-usage-efficiency * [ 1 + (hh-eco-pp * household-size) ] of apartment-household
    set apartment-usage-efficiency apartment-usage-efficiency * [ household-habits-eco ] of apartment-household
  ]
  ;;; Rent, energy, and maintenance computations ;;;

  set apartment-energy-consumption (24 - daylight-hours) * ((apartment-size * kwh-per-m2 * apartment-usage-efficiency) / (30 * 24))
  set apartment-energy-cost (floor ((apartment-energy-consumption * k-per-kwh * 100) )) / 100
  set apartment-energy-bill apartment-energy-bill + apartment-energy-cost
end

to buildings-update-variables
  let n n-dwellings
  let h count building-apartments with [apartment-occupied? and apartment-household != nobody] ; it can be nobody if we're in the middle of a renovation
  let r count building-apartments with [apartment-occupied? and apartment-household != nobody and [household-protesting?] of apartment-household]

  if n > 0 [
    (ifelse h > 0 and r / h > 0.5 [
      set color red
    ] any? building-apartments with [apartment-renovation-status = "not renovated"] [
      set color grey
    ] any? building-apartments with [apartment-renovation-status = "on-going"] [
      set color orange
    ] all? building-apartments [apartment-renovation-status = "completed"] [
      set color green
    ] [
      set color yellow
    ])
  ]
end

to-report building-residents
  report households with [ [apartment-building] of household-apartment = myself ]
end

to-report building-upgrade-choice [ option-list ]
  let people building-residents
  if any? people [ ; it is possible that buildings will be upgraded when they don't have any residents
    let votes [ household-choose-upgrade-option option-list ] of building-residents
    report one-of modes votes
  ]
  report one-of option-list
end

;{activities}
;{initialise activities' variables}
to activities-init-variables [a-building]
  set hidden? true
  move-to a-building
  set shape "triangle"
  set activity-building a-building
end

to-report activity-borough
  report [patch-borough] of patch-here
end


;{services}
;{initialise services' variables}
to services-init-variables [a-building]
  set hidden? true
  move-to a-building
  set shape "square"
  set service-building a-building
end

to-report service-borough
  report [patch-borough] of patch-here
end

to building-energy-efficiency-decay
  ask one-of building-apartments [
    apartments-energy-efficiency-decay
  ]
end

;{apartments}
;{decay of energy effiency}
to apartments-energy-efficiency-decay
  ; the 'efficiency' is somewhat misnamed -- higher values mean greater energy consumption
  set apartment-energy-efficiency (apartment-energy-efficiency + apartment-energy-efficiency-decay-rate)
end

;{apartments}
;{starts apartment renovation}
to apartments-renovation-starts [renovation-time]
  set apartment-renovation-time renovation-time ; time for the renovation to be completed
  set apartment-renovated? false
  set apartment-renovation-status "on-going" ; previously "not renovated" (and already set before moving households out)
end


;{apartments}
;{finish apartment renovation}
to apartments-renovation-ends
  set apartment-renovated? true
  set apartment-renovation-status "completed" ; previously "on-going"
  set apartment-newness this-year
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BOROUGHS' STATS TABLE
;;;;;;;;;;;;;;;;;;;;;;;;;
;{procedures associated with the management of the table storing info about each borough}
;{all procedures were moved here for convenience and increase readibility}


; {borough}
;
; Initialize data. Data sources:
;
; + Omrade: foreign-born, population, benefits (2018)
;   + Various 'omradesfakta' documents (PDFs)

to initialize-borough
  (ifelse borough-name = "Tensta" [
    set data-population 18877 ; N.B. derived from total utlansk bakgrund 2018 (9619) and % (88.3) as population table missing from Tensta's omradesfakta for some reason
    set data-flats 5944
    set data-social-flats 2021
    set data-foreign-born-p 0.883
    set data-benefits-p 0.08
    set data-benefits-kr 9637
    set data-employed-p 0.582 ; aged 20-64
    set data-mean-income-kr 226800 / 12 ; aged 20-64
    set data-omradesfakta-year 2018
    set borough-scb-id 0184 ; Solna
  ] borough-name = "Husby" [
    set data-population 11719
    set data-flats 4961
    set data-social-flats 2353
    set data-foreign-born-p 0.873
    set data-benefits-p 0.069
    set data-benefits-kr 9592
    set data-employed-p 0.606 ; aged 20-64
    set data-mean-income-kr 240400 / 12 ; aged 20-64
    set data-omradesfakta-year 2018
    set borough-scb-id 0184 ; Solna
  ] borough-name = "Kista" [
    set data-population 13208
    set data-flats 3931
    set data-social-flats 128
    set data-foreign-born-p 0.728
    set data-benefits-p 0.018
    set data-benefits-kr 9813
    set data-employed-p 0.703 ; aged 20-64
    set data-mean-income-kr 328200 / 12 ; aged 20-64
    set data-omradesfakta-year 2018
    set borough-scb-id 0184 ; Solna
  ] borough-name = "Rinkeby" [
    set data-population 15603
    set data-flats 5367
    set data-social-flats 2857
    set data-foreign-born-p 0.913
    set data-benefits-p 0.094
    set data-benefits-kr 10338
    set data-employed-p 0.532 ; aged 20-64
    set data-mean-income-kr 213200 / 12 ; aged 20-64
    set data-omradesfakta-year 2018
    set borough-scb-id 0184 ; Solna
  ] borough-name = "Akalla" [
    set data-population 9071
    set data-flats 3299
    set data-social-flats 915
    set data-foreign-born-p 0.789
    set data-benefits-p 0.031
    set data-benefits-kr 8942
    set data-employed-p 0.676 ; aged 20-64
    set data-mean-income-kr 277100 / 12 ; aged 20-64
    set data-omradesfakta-year 2018
    set borough-scb-id 0184 ; Solna
  ] [
    output-error (word "Unrecognized borough-name: \"" borough-name "\"")
  ])
  ; N.B. When I later come to do Malmo here, borough-scb-id should be 1280
end

to-report borough-random-income
  let income-var income-sd ^ 2
  report random-gamma (data-mean-income-kr * data-mean-income-kr / income-var) (data-mean-income-kr / income-var)
end

to-report borough-sample-by-flats
  let borough-list []
  let weights []

  ask boroughs [
    set borough-list lput self borough-list
    set weights lput (data-flats + data-social-flats) weights
  ]

  report item (weighted-sample-index weights) borough-list
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ENVIRONMENT
;;;;;;;;;;;;;;;;;;;;;;;;;
;{this file manages natural enviroment of SMARTEES Stockholm simulations}
;{each procedure starts with a reference "env", abbreviation for "environment"}

;;; PROCEDURES ;;;

;{world}
;{read the csv with the weather forecasts associated with the selected scenario and store in a local table}
to env-read-weather-data

  let env-weather-dir "Data/env-weather/"
  let selected-scenario climate ; select from the interface
  let weather-file (word env-weather-dir "Sweden-Ostra_Svealand-Stockholm-1961-2100-" selected-scenario ".csv")

  set env-weather-list [] ; year average-temperature sd-temperature


  if not file-exists? weather-file [ output-error (word "Weather file does not found. Please, check file names and directory.") ]
  file-open weather-file
  let header file-read-line
  while [not file-at-end?] [
    let data csv:from-row file-read-line
    let year-info []
    set year-info lput item 0 data year-info ; year
    set year-info lput item 1 data year-info ; avg-temp
    set year-info lput item 2 data year-info ; sd-temp
    set env-weather-list lput year-info env-weather-list
    set year-info []
  ]
  file-close

  let env-monthly-list [ [] [] [] [] [] [] [] [] [] [] [] [] ]
  let env-year-mean-list []

  let historical-weather-file (word env-weather-dir "stockholm-historical-temps-monthly-3/csv/stockholm_monthly_mean_temperature_1756_2020_adjust.csv")
  file-open historical-weather-file
  set header csv:from-row file-read-line
  while [not file-at-end?] [
    let data csv:from-row file-read-line
    let year first data
    if year >= climate-calib-y-start and year <= climate-calib-y-end [
      set env-year-mean-list lput (last data) env-year-mean-list

      let month-mean sublist data 1 13
      set env-monthly-list (map [ [ a b ] -> lput b a ] env-monthly-list month-mean)
    ]
  ]
  file-close
  set env-year-mean mean env-year-mean-list
  set env-monthly-mean (map [ i -> (mean i) - env-year-mean ] env-monthly-list)
  set env-monthly-sd (map [ i -> standard-deviation i ] env-monthly-list)
end

to-report days-in-year [year]
  report ifelse-value (year mod 100 = 0 or year mod 4 != 0) [ 365 ] [ 366 ]
end

to-report month-days-list [year]
  let month-days [ 31 28 31 30 31 30 31 31 30 31 30 31 ]
  if days-in-year year = 366 [
    set month-days replace-item 1 month-days 29
  ]
  report month-days
end

to-report past-days [days year]
  let month-days month-days-list year
  let sum-days reduce [              ; this horrendous command creates a list of cumulative sums...
    [ result next ] -> ifelse-value is-list? result [
      lput (next + last result) result
    ] [
      (list result (next + result))
    ]
  ] month-days                       ; ... surely there is a better way to do it!?
  report filter [ d -> d < days ] sum-days
end

to-report month-from-days [days year]
  report 1 + length past-days days year
end

to-report day-in-month [days year]
  report days - last past-days days year
end

to-report tick-year
  let day-count ticks
  let year start-year
  while [ days-in-year year > day-count ] [
    set year year + 1
    set day-count day-count - days-in-year year
  ]
  report year
end

to-report tick-month
  let day-count ticks
  let year start-year
  while [ days-in-year year > day-count ] [
    set year year + 1
    set day-count day-count - days-in-year year
  ]
  report month-from-days day-count year
end

to-report tick-day
  let day-count ticks
  let year start-year
  while [ days-in-year year > day-count ] [
    set year year + 1
    set day-count day-count - days-in-year year
  ]
  report day-in-month day-count year
end

to-report year-day [curr-year curr-month curr-day]
  let yd 0
  let md month-days-list curr-year
  foreach n-values (curr-month - 1) [i -> i] [ i ->
    set yd yd + item i md
  ]
  report yd + curr-day
end

to-report ticks-to-date [curr-year curr-month curr-day]
  if curr-year < start-year [
    output-error (word "Date " curr-year "/" curr-month "/" curr-day " is before model start date " start-year "/1/1")
  ]
  let tick-count 0
  let year start-year
  while [ year < curr-year ] [
    set tick-count tick-count + days-in-year year
    set year year + 1
  ]
  set tick-count tick-count + year-day curr-year curr-month curr-day
  report tick-count
end

to-report next-year [curr-year curr-month curr-day]
  let day curr-day + 1
  report ifelse-value (curr-month = 12 and day > item (curr-month - 1) month-days-list curr-year) [
    curr-year + 1
  ] [
    curr-year
  ]
end

to-report next-month [curr-year curr-month curr-day]
  let day curr-day + 1
  report ifelse-value (day > item (curr-month - 1) month-days-list curr-year) [
    ifelse-value curr-month = 12 [ 1 ] [ curr-month + 1 ]
  ] [
    curr-month
  ]
end

to-report next-day [curr-year curr-month curr-day]
  let day curr-day + 1
  report ifelse-value (day > item (curr-month - 1) month-days-list curr-year) [ 1 ] [ day ]
end

to-report end-of-the-month?
  report 1 = next-day this-year this-month this-day
end

to update-date
  let nx-day next-day this-year this-month this-day
  let nx-month next-month this-year this-month this-day
  let nx-year next-year this-year this-month this-day

  if this-month != nx-month [
    set n-months n-months + 1
  ]
  if this-year != nx-year [
    set n-years n-years + 1
  ]

  set this-day nx-day
  set this-month nx-month
  set this-year nx-year
end

to-report calc-daylight-hours [curr-year curr-month curr-day]
  let day-of-year year-day curr-year curr-month curr-day
  let rev-angle 0.2163108 + (2 * math:atan (0.9671396 * math:tan (0.00860 * (day-of-year - 186))))
  let declination math:asin (0.39795 * math:cos rev-angle)
  let p-frac (daylight-p * math:pi) / 180
  let l-frac (latitude * math:pi) / 180
  let daylight 24 - ((24 / math:pi) * math:acos (( p-frac + ((math:sin l-frac) * (math:sin declination)) ) / ((math:cos l-frac) * (math:cos declination))))
  report daylight
end

;{world}
;{set temperature for today}
; Also sets daylight hours
to env-set-today-temperature

;  if ceiling(ticks / 365) != this-year - starting-year
;  [ set this-year ceiling(ticks / 365) ] b

  let env-weather-list-filtered filter [ data -> first data = this-year ] env-weather-list
  let env-weather-list-filtered-unlisted item 0 env-weather-list-filtered
  let climate-mean item 1 env-weather-list-filtered-unlisted
  let climate-stdev item 2 env-weather-list-filtered-unlisted

  let annual-diff-sample (random-normal climate-mean climate-stdev) + env-year-mean
  set today-temperature annual-diff-sample + random-normal (item (this-month - 1) env-monthly-mean) (item (this-month - 1) env-monthly-sd)
  set today-temperature precision today-temperature 2

  set daylight-hours calc-daylight-hours this-year this-month this-day
end

to initialize-scb [ scb-dir ]
  set scb-cpi-year n-values 15 [ i -> i + 2006 ] ; (2006 to 2020)
  ; Annual average Consumer Price Index 2006-2020
  ; https://www.scb.se/en/finding-statistics/statistics-by-subject-area/prices-and-consumption/consumer-price-index/consumer-price-index-cpi/pong/tables-and-graphs/consumer-price-index-cpi/cpi-1949100/
  ; Accessed 13 May 2022
  set scb-cpi-index [ 1623 1659 1716 1711 1733 1778 1794 1793 1790 1789 1807 1839 1875 1909 1918 ]
  set scb-building-year read-scb-csv (word scb-dir "/building-construction-year.csv")
  set scb-building-floor read-scb-csv (word scb-dir "/building-floor-space.csv")
  set scb-building-tenancy read-scb-csv (word scb-dir "/building-tenancy.csv")
  set scb-household-type read-scb-csv (word scb-dir "/household-type.csv")
  set scb-household-floor read-scb-csv (word scb-dir "/household-type-floor-space.csv")
  set scb-household-tenancy read-scb-csv (word scb-dir "/household-tenancy.csv") ; N.B. unused as at 2022-05-10
  set scb-household-decile read-scb-csv (word scb-dir "/household-income-decile-upper-bounds.csv")
  set scb-household-expense read-scb-csv (word scb-dir "/household-expenditures-" HBS-year ".csv")
  set scb-xp-food ["r002"]
  set scb-xp-clothes ["r102"]
  ; N.B. leisure time and culture is "r129" and inludes "r138" and "r139", which I've put as comms. "r129" does not include eating out.
  set scb-xp-leisure ["r092" "r130" "r132" "r134" "r135" "r136" "r137"] ; dinner out, weekend cottage, sport and hobby, holidays, other spare time, entertainment, books and newspapers
  set scb-xp-health ["r096" "r120"] ; personal hygiene, health and hospital
  set scb-xp-comms ["r131" "r138" "r139"] ; radio and TV, mobile telephone, telephone
  set scb-xp-home ["r111" "r112" "r113" "r116"] ; repairs, insurance, services, furnishings, etc.
  set scb-xp-childcare ["r099"]
  set scb-xp-goods ["r095" "r133"] ; consumer goods, watch, camera, photographic
  set scb-xp-transport ["r121"]
  set scb-xp-narcotics ["r093" "r094"] ; tobacco and alcohol
  ; Check all the consumption data are available and adjust parameter switches accordingly

  if xp-food? [
    set xp-food? all-deciles-have? scb-xp-food
    if not xp-food? [
      output-warning "Switched xp-food? off because not all expenditure items found"
    ]
  ]
  if xp-clothes? [
    set xp-clothes? all-deciles-have? scb-xp-clothes
    if not xp-clothes? [
      output-warning "Switched xp-clothes? off because not all expenditure items found"
    ]
  ]
  if xp-leisure? [
    set xp-leisure? all-deciles-have? scb-xp-leisure
    if not xp-leisure? [
      output-warning "Switched xp-leisure? off because not all expenditure items found"
    ]
  ]
  if xp-health? [
    set xp-health? all-deciles-have? scb-xp-health
    if not xp-health? [
      output-warning "Switched xp-health? off because not all expenditure items found"
    ]
  ]
  if xp-comms? [
    set xp-comms? all-deciles-have? scb-xp-comms
    if not xp-comms? [
      output-warning "Switched xp-comms? off because not all expenditure items found"
    ]
  ]
  if xp-home? [
    set xp-home? all-deciles-have? scb-xp-home
    if not xp-home? [
      output-warning "Switched xp-home? off because not all expenditure items found"
    ]
  ]
  if xp-childcare? [
    set xp-childcare? all-deciles-have? scb-xp-childcare
    if not xp-childcare? [
      output-warning "Switched xp-childcare? off because not all expenditure items found"
    ]
  ]
  if xp-goods? [
    set xp-goods? all-deciles-have? scb-xp-goods
    if not xp-goods? [
      output-warning "Switched xp-goods? off because not all expenditure items found"
    ]
  ]
  if xp-transport? [
    set xp-transport? all-deciles-have? scb-xp-transport
    if not xp-transport? [
      output-warning "Switched xp-transportd? off because not all expenditure items found"
    ]
  ]
  if xp-narcotics? [
    set xp-narcotics? all-deciles-have? scb-xp-narcotics
    if not xp-narcotics? [
      output-warning "Switched xp-narcotics? off because not all expenditure items found"
    ]
  ]

end

to-report all-deciles-have? [ good-list ]
  foreach good-list [ good ->
    if not all-deciles-have-good? good [
      report false
    ]
  ]
  report true
end

to-report all-deciles-have-good? [ good ]
  let deciles map [ x -> (word "D" x) ] n-values 10 [ i -> i + 1 ]
  foreach scb-household-expense [ row-data ->
    let scb-decile table:get row-data "Decile ID"
    let scb-good table:get row-data "Good ID"

    if scb-good = good and member? scb-decile deciles [
      set deciles remove scb-decile deciles
    ]
  ]
  report (length deciles = 0)
end

to-report read-scb-csv [ filename ]
  let data []
  let csv-data csv:from-file filename
  let csv-headings first csv-data
  let first-heading first csv-headings
  let first-char first first-heading
  while [ not ((first-char >= "A" and first-char <= "Z") or (first-char < "a" and first-char > "z")) and length first-heading > 0 ] [
    set first-heading but-first first-heading
    set first-char first first-heading
  ]
  if length first-heading = 0 [
    output-error (word "No usable heading name in first column of first row of \"" filename "\" (\"" (first csv-headings) "\")")
  ]
  set csv-headings fput first-heading (but-first csv-headings)
  let prev-data table:make
  foreach but-first csv-data [ row ->
    let row-data table:make

    ifelse length row = length csv-headings [
      (foreach csv-headings row [ [column entry] ->
        (ifelse entry = "" and table:has-key? prev-data column [
          table:put row-data column (table:get prev-data column)
        ] entry != "" and entry != ".." [
          table:put row-data column entry
          table:put prev-data column entry
        ] entry = ".." [
          table:put row-data column 0
          table:put prev-data column 0
        ] [
          output-warning (word "No data for \"" column "\" in a row of  \"" filename "\"")
        ])
      ])
    ] [
      output-warning (word "Row in \"" filename "\" has different number of entries (" (length row) ") than header row (" (length csv-headings) ")")
    ]

    set data lput row-data data
  ]
  report data
end

; {Building} scb-sample-building-year
;
; Use the SCB data to take a weighted sample of the year of construction of the building

to-report scb-sample-building-year
  let scb-municipality [borough-scb-id] of building-borough
  let construction-years []
  let weights []
  foreach scb-building-year [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-building-type-name table:get row-data "Building Type Name"
    let scb-construction-year-name table:get row-data "Construction Year Name"
    let scb-count-dwellings table:get row-data scb-year

    if scb-region-id = scb-municipality and scb-building-type-name = building-scb-type and scb-construction-year-name != "data missing" [
      if (is-number? scb-construction-year-name and abs scb-construction-year-name < start-year)
      or (is-string? scb-construction-year-name and read-from-string substring scb-construction-year-name 0 4 < start-year) [
        set construction-years lput scb-construction-year-name construction-years
        set weights lput scb-count-dwellings weights
      ]
    ]
  ]
  let const-year-range item (weighted-sample-index weights) construction-years
  if const-year-range = -1930 or const-year-range = "-1930" [
    report 1930
  ]
  let year-min 0
  let year-max 0
  carefully [
    set year-min read-from-string substring const-year-range 0 4
    set year-max read-from-string substring const-year-range 5 9
  ] [
    output-error (word "Could not get a year range from \"" const-year-range "\" -- minimum \"" (substring const-year-range 0 4) "\"; maximum \"" (substring const-year-range 5 9) "\": " error-message)
  ]
  report year-min + random (1 + year-max - year-min)
end

; {Apartment} scb-sample-building-floor
;
; Use the SCB data to take a weighted sample of the floor-space in an apartment

to-report scb-sample-building-floor
  let scb-municipality [borough-scb-id] of apartment-borough
  let my-scb-building-type [building-scb-type] of apartment-building
  let floor-spaces []
  let weights []
  foreach scb-building-floor [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-building-type-name table:get row-data "Building Type Name"
    let scb-floor-space table:get row-data "Floor Space Name"
    let scb-count-dwellings table:get row-data scb-year

    if scb-region-id = scb-municipality and scb-building-type-name = my-scb-building-type and scb-floor-space != "data missing" [
      set floor-spaces lput scb-floor-space floor-spaces
      set weights lput scb-count-dwellings weights
    ]
  ]
  let floor-space-range item (weighted-sample-index weights) floor-spaces
  if item 0 floor-space-range = "<" [
    report (read-from-string substring floor-space-range 2 4) - 1 ; Assumes a two-digit minimum floor space range (e.g. "< 31 sq.m.")
  ]
  if item 0 floor-space-range = ">" [
    report (read-from-string substring floor-space-range 2 5) + 1 ; Assumes a three-digit maximum floor space range (e.g. "> 200 sq.m.")
  ]
  let dash position "-" floor-space-range
  let space position " " floor-space-range
  let space-min read-from-string substring floor-space-range 0 dash
  let space-max read-from-string substring floor-space-range (dash + 1) space
  report space-min + random (1 + space-max - space-min)
end

; {Apartment} scb-sample-building-tenancy
;
; Use the SCB data to take a weighted sample of the tenancy of an apartment

to-report scb-sample-building-tenancy
  let scb-municipality [borough-scb-id] of apartment-borough
  let my-scb-building-type [building-scb-type] of apartment-building
  let tenancies []
  let weights []
  foreach scb-building-tenancy [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-building-type-name table:get row-data "Building Type Name"
    let scb-tenancy table:get row-data "Tenancy Name"
    let scb-count-dwellings table:get row-data scb-year

    if scb-region-id = scb-municipality and scb-building-type-name = my-scb-building-type and scb-tenancy != "data missing" [
      set tenancies lput scb-tenancy tenancies
      set weights lput scb-count-dwellings weights
    ]
  ]
  report item (weighted-sample-index weights) tenancies
end


; {Household} scb-get-household-floor-space

to-report scb-get-household-floor-space [ hh-type dw-type ]
  let scb-municipality [borough-scb-id] of household-borough
  let floor-space -1
  foreach scb-household-floor [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-hh-type-id table:get row-data "Household Type ID"
    let scb-dwelling-type table:get row-data "Dwelling Type ID"

    if scb-region-id = scb-municipality and scb-hh-type-id = hh-type and scb-dwelling-type = dw-type [
      let scb-floor-space table:get row-data scb-year
      ifelse floor-space = -1 [
        set floor-space scb-floor-space
      ] [
        if floor-space != scb-floor-space [
          output-error (word "Duplicate entry for region \"" scb-region-id "\", household type \"" scb-hh-type-id "\", dwelling type \"" scb-dwelling-type "\" in household-type-floor-space file (" floor-space ", " scb-floor-space ")")
        ]
      ]
    ]
  ]
  if floor-space = -1 or floor-space = ".." [
    output-error (word "No data for region \"" scb-municipality "\", household type \"" hh-type "\", dwelling type \"" dw-type "\" in household-type-floor-space file")
  ]
  report floor-space
end

; {Household} scb-sample-household-dwelling-type

to-report scb-sample-household-dwelling-type [ hh-type ]
  let scb-municipality [borough-scb-id] of household-borough
  let dwellings []
  let weights []
  foreach scb-household-type [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-hh-type-id table:get row-data "Household Type ID"
    let scb-dwelling-type table:get row-data "Dwelling Type ID"
    let scb-count-hh table:get row-data scb-year

    let scb-dw-2 substring scb-dwelling-type 0 2
    let scb-include-dw-type? ifelse-value only-rented? [
      scb-dwelling-type = "SMHY0" or scb-dwelling-type = "FBHY0"
    ] [
      scb-dw-2 = "SM" or scb-dw-2 = "FB"
    ]
    if scb-region-id = scb-municipality and scb-hh-type-id = hh-type and scb-include-dw-type? and scb-count-hh != ".." [
      set dwellings lput scb-dwelling-type dwellings
      set weights lput scb-count-hh weights
    ]
  ]
  report item (weighted-sample-index weights) dwellings
end

; {Household} scb-sample-household-type

to-report scb-sample-household-type
  let scb-municipality [borough-scb-id] of household-borough
  let hh-types []
  let weights []
  foreach scb-household-type [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-hh-type-id table:get row-data "Household Type ID"
    let scb-dwelling-type table:get row-data "Dwelling Type ID"
    let scb-count-hh table:get row-data scb-year

    if scb-region-id = scb-municipality and scb-dwelling-type = "TOT" and scb-hh-type-id != "SAMTLH" [
      set hh-types lput scb-hh-type-id hh-types
      set weights lput scb-count-hh weights
    ]
  ]
  report item (weighted-sample-index weights) hh-types
end

to-report scb-get-household-income-decile
  let scb-municipality [borough-scb-id] of household-borough
  let annual-income-k scb-convert-cpi (household-income * 12 / 1000) ([data-omradesfakta-year] of household-borough) scb-year
  foreach scb-household-decile [ row-data ->
    let scb-region-id table:get row-data "Region ID"
    let scb-decile table:get row-data "Decile ID"
    let scb-upper-bound table:get row-data scb-year
    let scb-metric table:get row-data "Metric ID"

    if scb-region-id = scb-municipality and scb-metric = "DispInkExklEjke" and scb-decile != "D10" and scb-upper-bound > annual-income-k [
      ; "DispInkExklEjke" is "disposable income excluding capital gains"
      ; D10 has upper bound ".." (obvs.)
      report scb-decile
    ]
  ]
  report "D10"
end

to-report scb-include-expense? [ children? good ]
  report ((xp-food? and member? good scb-xp-food) or (xp-clothes? and member? good scb-xp-clothes) or (xp-leisure? and member? good scb-xp-leisure)
    or (xp-health? and member? good scb-xp-health) or (xp-comms? and member? good scb-xp-comms) or (xp-home? and member? good scb-xp-home)
    or (children? and xp-childcare? and member? good scb-xp-childcare) or (xp-goods? and member? good scb-xp-goods)
    or (xp-transport? and member? good scb-xp-transport) or (xp-narcotics? and member? good scb-xp-narcotics))
end

to-report scb-get-household-expenses [ hh-type ]
  let decile scb-get-household-income-decile
  let total 0
  let margin 0
  let n-children scb-hh-children-from-hh-type hh-type
  foreach scb-household-expense [ row-data ->
    let scb-decile table:get row-data "Decile ID"
    let scb-good table:get row-data "Good ID"
    let scb-expenditure table:get row-data "Expenditures"
    let scb-margin table:get row-data "Expenditures -- margin of error"
    let scb-persons table:get row-data "Average number of persons"

    if scb-decile = decile and is-number? scb-expenditure and scb-include-expense? (n-children > 0) scb-good [
      ; N.B. ".." is used if the expenditure is not applicable -- assume zero
      set total total + ((scb-expenditure / 12) * (household-size / scb-persons))
      if is-number? scb-margin [
        ; Just in case margin is ever ".." if expense isn't
        set margin margin + ((scb-margin / 12) * (household-size / scb-persons))
      ]
    ]
  ]
  set total scb-convert-cpi total HBS-year ([data-omradesfakta-year] of household-borough)
  set margin scb-convert-cpi margin HBS-year ([data-omradesfakta-year] of household-borough)
  report (list total margin)
end

to-report scb-convert-cpi [ amount from-year to-year ]
  let from-cpi 0
  let to-cpi 0
  (foreach scb-cpi-year scb-cpi-index [ [year cpi] ->
    if year = from-year [
      set from-cpi cpi
    ]
    if year = to-year [
      set to-cpi cpi
    ]
  ])
  if from-cpi = 0 or to-cpi = 0 [
    output-error (word "Could not convert " amount "kr from " from-year " to " to-year " because one or more of those years not in scb-cpi-year list")
  ]
  report amount * (to-year / from-year)
end

to-report weighted-sample-index [ weight-list ]
  if length weight-list = 0 [
    output-error "weighted-sample-index called with empty weight-list"
  ]
  let weighted-sum reduce [ [ so-far next ] -> lput (next + ifelse-value (length so-far = 0) [0] [last so-far]) so-far ] (fput [] weight-list)
  let chosen random last weighted-sum
  let chosen-index length filter [ w -> w <= chosen ] weighted-sum
  report chosen-index
end

to-report scb-gender-from-hh-type [ hh-type ]
  report (ifelse-value (hh-type = "LEK" or hh-type = "LEKP" or hh-type = "LEKB") [ "F" ]
    (hh-type = "LEM" or hh-type = "LEMP" or hh-type = "LEMB") [ "M" ] [ "C" ])
end

to-report scb-n-wage-from-hh-type [ hh-type ]
  report (ifelse-value (hh-type = "LEK" or hh-type = "LEM" or hh-type = "LEKB" or hh-type = "LEMB") [ 1 ]
    (hh-type = "LS" or hh-type = "LS1" or hh-type = "LS2" or hh-type = "LS3" or hh-type = "LO" or hh-type = "LOMB") [ 2 ] [ 0 ])
    ; N.B. LO/MB is 'other' households with/without children
    ; 0 wage-earners could be pensioners LEKP and LEMP and possibly some 'other' households too.
end

to-report scb-hh-size-from-hh-type [ hh-type ]
  report scb-n-wage-from-hh-type hh-type + scb-hh-children-from-hh-type hh-type + ifelse-value (hh-type = "LEKP" or hh-type = "LEMP" or hh-type = "LO" or hh-type = "LOMB") [ 1 ] [ 0 ]
  ; N.B. This basically assumes 'other' households have one adult non-wage earning member
end

to-report scb-hh-children-from-hh-type [ hh-type ]
  report (ifelse-value (hh-type = "LS1") [ 1 ] (hh-type = "LEKB" or hh-type = "LEMB" or hh-type = "LS2" or hh-type = "LOMB") [ 2 ] (hh-type = "LS3") [ 3 ] [ 0 ])
  ; Single-parent and 'other' households assumed to have two children
end

to-report scb-building-type-from-dwelling-type [ dw-type ]
  report (ifelse-value (dw-type = "SMAG" or dw-type = "SMBO" or dw-type = "SMHY0") [ "one- or two-dwelling buildings" ]
    (dw-type = "FBBO" or dw-type = "FBHY0") [ "multi-dwelling-buildings" ]
    (dw-type = "SPBO") [ "special housing" ] [ "other buildings" ])
end

to-report scb-tenancy-type-from-dwelling-type [ dw-type ]
  report (ifelse-value (dw-type = "SMAG") [ "owner-occupied dwellings" ]
    (dw-type = "SMBO" or dw-type = "FBBO") [ "tenant-owned dwellings" ]
    (dw-type = "SMHY0" or dw-type = "FBHY0") [ "rented dwellings" ] [ "unknown" ])
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; notifications
;;;;;;;;;;;;;;;;;;;;;;;;;

to output-error [string]
  error string
  set error? true
end

to output-warning [string]
  if warnings = 0 [
    set warnings table:make
  ]
  ifelse table:has-key? warnings string [
    table:put warnings string 1 + table:get warnings string
  ] [
    output-print (word "WARNING [" timer "]: " string)
    table:put warnings string 1
  ]
end

to output-note [string]
  if notes = 0 [
    set notes table:make
  ]
  ifelse table:has-key? notes string [
    table:put notes string 1 + table:get notes string
  ] [
    output-print (word "NOTE [" timer "]: " string)
    table:put notes string 1
  ]
end

to print-progress [string]
  print (word "PROGRESS [" timer "]: " string)
end
@#$#@#$#@
GRAPHICS-WINDOW
419
10
1628
680
-1
-1
1.0
1
20
1
1
1
0
0
0
1
-600
600
-330
330
1
1
1
days
30.0

BUTTON
10
40
73
73
setup
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
1634
10
2061
220
11

MONITOR
219
243
293
280
n-apartments
count apartments
17
1
9

PLOT
1848
346
2061
466
Rents
SEK/month
n
0.0
20000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1000.0 1 -16777216 true "" "histogram [apartment-rent] of apartments"

PLOT
1634
468
1846
588
Energy consumption
kWh/day
n
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [apartment-energy-consumption] of apartments with [apartment-occupied?]"

SWITCH
590
685
696
718
network?
network?
0
1
-1000

BUTTON
74
40
138
73
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
139
40
204
73
run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1930
706
2062
739
en-eff-decay
en-eff-decay
0
0.01
1.0E-4
0.0001
1
NIL
HORIZONTAL

SLIDER
419
821
589
854
hh-init-eco-habits
hh-init-eco-habits
0
2
1.0
0.01
1
NIL
HORIZONTAL

PLOT
9
429
413
563
energy use
Day
kWh/day
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "plot mean [apartment-energy-consumption] of apartments with [apartment-occupied?]"
"median" 1.0 0 -7500403 true "" "plot median [apartment-energy-consumption] of apartments with [apartment-occupied?]"
"min" 1.0 0 -2674135 true "" "plot min [apartment-energy-consumption] of apartments with [apartment-occupied?]"
"max" 1.0 0 -13345367 true "" "plot max [apartment-energy-consumption] of apartments with [apartment-occupied?]"

PLOT
9
281
413
428
sentiment
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"money" 1.0 0 -10899396 true "" "plot count households with [unhappy-money?]"
"crime" 1.0 0 -16777216 true "" "plot count households with [unhappy-crime?]"
"mix" 1.0 0 -8630108 true "" "plot count households with [unhappy-heterophily?]"
"race" 1.0 0 -2674135 true "" "plot count households with [unhappy-racism?]"
"trust" 1.0 0 -13345367 true "" "plot count households with [household-trust > 0.5]"

PLOT
1634
346
1846
466
Apartments year
NIL
NIL
1930.0
2020.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [apartment-newness] of apartments"

CHOOSER
208
86
300
131
climate
climate
"RCP2.6" "RCP4.5" "RCP8.5"
2

MONITOR
10
74
137
123
Date
(word this-year \"-\" this-month \"-\" this-day)
17
1
12

PLOT
1848
468
2061
588
Temperature & Daylight
Day
C & h
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"temp" 1.0 0 -16777216 true "" "plot today-temperature"
"light" 1.0 0 -2674135 true "" "plot daylight-hours"

SLIDER
1632
604
1740
637
start-year
start-year
1970
2020
2010.0
1
1
NIL
HORIZONTAL

SLIDER
1632
672
1793
705
climate-calib-y-start
climate-calib-y-start
1800
1950
1850.0
1
1
NIL
HORIZONTAL

SLIDER
1794
672
1950
705
climate-calib-y-end
climate-calib-y-end
1800
1950
1950.0
1
1
NIL
HORIZONTAL

SLIDER
1838
604
1943
637
n-activities
n-activities
100
5000
200.0
100
1
NIL
HORIZONTAL

SLIDER
1741
604
1837
637
n-services
n-services
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1136
753
1248
786
p-criminal
p-criminal
0
0.2
0.015
0.001
1
NIL
HORIZONTAL

SLIDER
512
719
618
752
n-ethnicities
n-ethnicities
1
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
1146
685
1283
718
homophily-min
homophily-min
0
1
0.5
0.001
1
NIL
HORIZONTAL

SLIDER
1284
685
1422
718
homophily-max
homophily-max
0
1
0.901
0.001
1
NIL
HORIZONTAL

SLIDER
1949
774
2062
807
dwellings-per-tower-block
dwellings-per-tower-block
1
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
1908
740
2062
773
dwellings-per-terrace
dwellings-per-terrace
0
50
20.0
1
1
NIL
HORIZONTAL

SWITCH
1885
638
2062
671
apartments-in-houses?
apartments-in-houses?
0
1
-1000

SLIDER
1486
753
1608
786
crime-cost
crime-cost
0
10000
1000.0
100
1
k
HORIZONTAL

SLIDER
1346
753
1485
786
crime-benefit
crime-benefit
0
100000
10000.0
1000
1
k
HORIZONTAL

SLIDER
1249
753
1345
786
p-crime
p-crime
0
0.1
0.035
0.001
1
NIL
HORIZONTAL

SLIDER
1047
719
1184
752
max-walk-dist
max-walk-dist
0
5
1.1
0.1
1
km
HORIZONTAL

SLIDER
1278
719
1418
752
max-cycle-dist
max-cycle-dist
0
10
3.1
0.1
1
km
HORIZONTAL

SLIDER
419
787
589
820
n-services-per-hh
n-services-per-hh
0
20
6.0
1
1
NIL
HORIZONTAL

SLIDER
1185
719
1277
752
p-cycle
p-cycle
0
1
0.15
0.01
1
NIL
HORIZONTAL

SWITCH
1419
719
1608
752
routines-include-routes?
routines-include-routes?
1
1
-1000

SLIDER
590
787
736
820
eth-1-min-reach
eth-1-min-reach
0
20
5.0
0.1
1
NIL
HORIZONTAL

SLIDER
737
787
890
820
eth-ge2-min-reach
eth-ge2-min-reach
0
20
4.1
0.1
1
NIL
HORIZONTAL

SLIDER
590
821
736
854
eth-1-max-reach
eth-1-max-reach
0
20
8.0
0.1
1
NIL
HORIZONTAL

SLIDER
737
821
890
854
eth-ge2-max-reach
eth-ge2-max-reach
0
20
6.0
0.1
1
NIL
HORIZONTAL

SLIDER
590
753
736
786
eth-1-work-reach
eth-1-work-reach
0
20
4.5
0.1
1
NIL
HORIZONTAL

SLIDER
737
753
890
786
eth-ge2-work-reach
eth-ge2-work-reach
0
20
3.0
0.1
1
NIL
HORIZONTAL

PLOT
9
836
413
956
node degree distribution
degree
n
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"ethnicity 1" 5.0 0 -16777216 true "" "histogram [count social-tie-neighbors] of households with [household-ethnicity = 1]"
"ethnicity 2" 5.0 0 -13345367 true "" "histogram [count social-tie-neighbors] of households with [household-ethnicity = 2]"
"ethnicity 3" 5.0 0 -5298144 true "" "histogram [count social-tie-neighbors] of households with [household-ethnicity = 3]"
"ethnicity > 3" 5.0 0 -10899396 true "" "histogram ifelse-value n-ethnicities > 3 [[count social-tie-neighbors] of households with [household-ethnicity > 3 and random (n-ethnicities - 3) = 0]] [ [0] ]"

SLIDER
813
685
966
718
circles-max-move
circles-max-move
0
50
10.45
0.05
1
NIL
HORIZONTAL

SLIDER
967
685
1145
718
circles-max-move-work
circles-max-move-work
0
50
8.2
0.05
1
NIL
HORIZONTAL

SLIDER
697
685
812
718
n-daily-visits
n-daily-visits
0
20
5.0
1
1
NIL
HORIZONTAL

MONITOR
9
243
76
280
NIL
patch-km
6
1
9

MONITOR
77
243
151
280
NIL
max-walk
1
1
9

MONITOR
152
243
219
280
NIL
max-cycle
1
1
9

CHOOSER
208
40
413
85
model-area
model-area
"Jarva/Stockholm" "Augustenborg/Malmo"
0

SLIDER
1512
787
1545
956
income-sd
income-sd
100
10000
4000.0
100
1
k/mon
VERTICAL

PLOT
9
715
413
835
household finances
income
n
-50000.0
15000.0
0.0
10.0
true
false
"" ""
PENS
"income (employed)" 5000.0 0 -16777216 true "" "histogram [household-income] of households with [household-employed?]"
"finances (unemployed)" 5000.0 0 -2674135 true "" "histogram ifelse-value (ticks >= 100) [[household-finance] of households with [not household-employed?]] [ [0] ]"
"finances (employed)" 5000.0 0 -13345367 true "" "histogram [household-finance] of households with [household-employed?]"

SLIDER
1808
706
1929
739
moves-per-tick
moves-per-tick
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1632
740
1761
773
options-per-move
options-per-move
1
10
5.0
1
1
NIL
HORIZONTAL

CHOOSER
419
707
511
752
scb-year
scb-year
2013 2014 2015 2016 2017 2018 2019 2020
0

PLOT
1634
222
1846
345
Floor space (buildings)
m^2
n
0.0
210.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [apartment-size] of apartments"

SLIDER
419
753
589
786
n-households
n-households
1000
20000
5500.0
100
1
NIL
HORIZONTAL

SWITCH
1944
604
2062
637
only-rented?
only-rented?
0
1
-1000

SLIDER
1632
706
1807
739
max-floor-space-diff
max-floor-space-diff
0
50
20.0
1
1
NIL
HORIZONTAL

PLOT
9
564
413
714
move waiting list
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"waiting" 1.0 0 -16777216 true "" "plot lt:length move-waiting-list"
"moved" 1.0 0 -7500403 true "" "plot n-moved"

SLIDER
590
855
736
888
eth-1-min-trust
eth-1-min-trust
0
1
0.8
0.001
1
NIL
HORIZONTAL

SLIDER
590
889
736
922
eth-1-max-trust
eth-1-max-trust
0
1
1.0
0.001
1
NIL
HORIZONTAL

SLIDER
737
855
890
888
eth-ge2-min-trust
eth-ge2-min-trust
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
737
889
890
922
eth-ge2-max-trust
eth-ge2-max-trust
0
1
0.7
0.001
1
NIL
HORIZONTAL

SLIDER
891
821
1051
854
forgiveness-crime
forgiveness-crime
0
1000
300.0
10
1
d
HORIZONTAL

SLIDER
891
855
1051
888
forgetting-crime
forgetting-crime
0
1000
600.0
10
1
d
HORIZONTAL

SLIDER
891
889
1051
922
tolerance-crime
tolerance-crime
0
20
2.0
1
1
x
HORIZONTAL

SLIDER
891
753
1012
786
mtg-d-trust
mtg-d-trust
0
1
0.26
0.01
1
NIL
HORIZONTAL

SLIDER
1052
821
1204
854
forgiveness-money
forgiveness-money
0
1000
50.0
10
1
d
HORIZONTAL

SLIDER
1052
855
1204
888
forgetting-money
forgetting-money
0
1000
120.0
10
1
d
HORIZONTAL

SLIDER
1052
889
1204
922
tolerance-money
tolerance-money
0
50
10.0
1
1
x
HORIZONTAL

SLIDER
1205
821
1357
854
forgiveness-hetero
forgiveness-hetero
0
1000
10.0
10
1
d
HORIZONTAL

SLIDER
1205
855
1357
888
forgetting-hetero
forgetting-hetero
0
1000
150.0
10
1
d
HORIZONTAL

SLIDER
1205
889
1357
922
tolerance-hetero
tolerance-hetero
0
100
20.0
1
1
x
HORIZONTAL

SLIDER
1358
821
1511
854
forgiveness-racism
forgiveness-racism
0
1000
20.0
10
1
d
HORIZONTAL

SLIDER
1358
855
1511
888
forgetting-racism
forgetting-racism
0
1000
300.0
10
1
d
HORIZONTAL

SLIDER
1358
889
1511
922
tolerance-racism
tolerance-racism
0
100
5.0
1
1
x
HORIZONTAL

SLIDER
891
787
1051
820
range-crime
range-crime
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1052
787
1204
820
range-money
range-money
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1205
787
1357
820
range-hetero
range-hetero
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
1358
787
1511
820
range-racism
range-racism
0
1
0.12
0.01
1
NIL
HORIZONTAL

SWITCH
1423
685
1608
718
networked-unhappiness?
networked-unhappiness?
1
1
-1000

PLOT
1848
222
2061
345
Household eco efficiency
NIL
NIL
0.0
2.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" "histogram [ household-habits-eco ] of households"

SLIDER
419
855
589
888
range-hh-init-eco
range-hh-init-eco
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
419
889
589
922
min-eco-habits
min-eco-habits
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
419
923
589
956
hh-eco-pp
hh-eco-pp
0
0.1
0.05
0.001
1
NIL
HORIZONTAL

SLIDER
590
923
736
956
eth-1-protest-min
eth-1-protest-min
1
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
737
923
890
956
eth-ge2-protest-min
eth-ge2-protest-min
1
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
1013
753
1135
786
visit-d-trust
visit-d-trust
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
891
923
1051
956
crime-d-trust
crime-d-trust
0
0.1
0.007
0.001
1
NIL
HORIZONTAL

SLIDER
1052
923
1204
956
money-d-trust
money-d-trust
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
1205
923
1357
956
hetero-d-trust
hetero-d-trust
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
1358
923
1511
956
racism-d-trust
racism-d-trust
0
0.1
0.002
0.001
1
NIL
HORIZONTAL

SLIDER
1590
821
1716
854
p-iv-crime
p-iv-crime
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1590
855
1716
888
p-iv-money
p-iv-money
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1590
889
1716
922
p-iv-hetero
p-iv-hetero
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
1590
923
1716
956
p-iv-racism
p-iv-racism
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
1717
821
1832
854
iv-mtg-mean
iv-mtg-mean
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
1717
855
1832
888
iv-lang-max
iv-lang-max
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
1717
889
1832
922
p-iv-habit
p-iv-habit
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
1717
923
1832
956
n-rand-iv
n-rand-iv
0
50
20.0
1
1
NIL
HORIZONTAL

INPUTBOX
245
132
345
192
intervention-file
iv-jarva-Sf-Leth-R3-Hx-Mx.csv
1
0
String

SLIDER
1833
787
1948
820
iv-n-buildings
iv-n-buildings
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
1833
889
1949
922
iv-min-start
iv-min-start
0
1000
500.0
10
1
NIL
HORIZONTAL

SLIDER
1833
923
1949
956
iv-min-dur
iv-min-dur
1
1000
50.0
10
1
NIL
HORIZONTAL

SLIDER
1950
923
2062
956
iv-max-dur
iv-max-dur
10
1000
500.0
10
1
NIL
HORIZONTAL

SLIDER
1590
787
1690
820
iv-opt-mean
iv-opt-mean
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
1950
855
2062
888
iv-rent-min
iv-rent-min
0
2
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
1950
889
2062
922
iv-rent-max
iv-rent-max
0
2
1.5
0.01
1
NIL
HORIZONTAL

SLIDER
1833
855
1949
888
iv-habit-max
iv-habit-max
0
1
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
425
686
588
704
Households and Social Networks
10
13.0
1

TEXTBOX
1770
590
1943
608
Buildings, Climate and Enviroment
10
52.0
1

TEXTBOX
1713
774
1780
792
Interventions
10
113.0
1

MONITOR
294
243
352
280
wating
count interventions with [ intervention-stage = \"unimplemented\" ]
17
1
9

MONITOR
353
243
413
280
done
count interventions with [ intervention-stage = \"finished\" ]
17
1
9

SLIDER
1632
638
1760
671
rent-per-m2
rent-per-m2
0
100
69.9
0.1
1
k
HORIZONTAL

SLIDER
1761
638
1884
671
kwh-per-m2
kwh-per-m2
0
20
12.78
0.01
1
NIL
HORIZONTAL

SLIDER
1951
672
2062
705
k-per-kwh
k-per-kwh
0
5
1.1
0.001
1
NIL
HORIZONTAL

SLIDER
1762
740
1907
773
en-eff-dk-p-yr
en-eff-dk-p-yr
0
0.01
0.0036
0.0001
1
NIL
HORIZONTAL

SLIDER
82
124
204
157
daylight-p
daylight-p
-180
180
0.833
0.001
1
NIL
HORIZONTAL

BUTTON
9
124
80
157
default-p
set daylight-p 0.833
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
138
74
204
123
daylight
(word (floor daylight-hours) \":\" (floor ((daylight-hours - floor daylight-hours) * 60)))
17
1
12

INPUTBOX
346
132
413
192
hh-file
0
1
0
String

BUTTON
9
168
64
201
iv
let iv user-file\nifelse is-string? iv [\n  set intervention-file iv\n] [\n  set intervention-file \"\"\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
66
168
121
201
hh
let hh user-new-file\nifelse is-string? hh [\n  set hh-file hh\n] [\n  set hh-file \"\"\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
11
157
121
175
interactive file selection
9
0.0
1

SLIDER
1546
787
1579
956
n-unhappy-move
n-unhappy-move
0
1000
365.0
1
1
d
VERTICAL

TEXTBOX
18
16
112
34
Wolverine 1.0
14
0.0
1

TEXTBOX
121
14
427
35
Funding from the European Union's Horizon 2020 Research & Innovation Programme. Project: SMARTEES; G/A no. 763912
9
5.0
1

SLIDER
741
719
833
752
p-eth-1
p-eth-1
0
1
0.0
0.01
1
NIL
HORIZONTAL

SWITCH
619
719
740
752
override-eth?
override-eth?
1
1
-1000

SLIDER
834
719
938
752
trust-ret
trust-ret
0
0.2
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
939
719
1046
752
trust-diff
trust-diff
0
1
0.215
0.005
1
NIL
HORIZONTAL

SLIDER
248
193
413
226
hh-file-write-frequency
hh-file-write-frequency
0
1000
0.0
1
1
NIL
HORIZONTAL

CHOOSER
301
86
413
131
hh-file-freq-units
hh-file-freq-units
"days" "weeks" "months" "years"
0

SLIDER
1950
821
2062
854
iv-nrg-max
iv-nrg-max
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1833
821
1949
854
iv-nrg-min
iv-nrg-min
0
1
0.1
0.01
1
NIL
HORIZONTAL

MONITOR
9
205
66
242
heap
mgr:heap-used-str
17
1
9

MONITOR
67
205
132
242
non-heap
mgr:non-heap-used-str
17
1
9

MONITOR
180
166
237
203
threads
mgr:threads
17
1
9

MONITOR
122
166
179
203
gc
mgr:gc-count
17
1
9

MONITOR
133
205
246
242
CPU
mgr:cpu-time-str
17
1
9

SWITCH
1691
787
1832
820
many-iv-p-bldg?
many-iv-p-bldg?
1
1
-1000

SWITCH
1482
14
1624
47
xp-food?
xp-food?
0
1
-1000

SWITCH
1482
47
1624
80
xp-clothes?
xp-clothes?
0
1
-1000

SWITCH
1482
212
1624
245
xp-childcare?
xp-childcare?
0
1
-1000

SWITCH
1482
179
1624
212
xp-home?
xp-home?
0
1
-1000

SWITCH
1482
146
1624
179
xp-comms?
xp-comms?
0
1
-1000

SWITCH
1482
113
1624
146
xp-health?
xp-health?
0
1
-1000

SWITCH
1482
80
1624
113
xp-leisure?
xp-leisure?
0
1
-1000

SWITCH
1482
245
1624
278
xp-goods?
xp-goods?
0
1
-1000

SWITCH
1482
278
1624
311
xp-transport?
xp-transport?
0
1
-1000

SWITCH
1482
311
1624
344
xp-narcotics?
xp-narcotics?
0
1
-1000

CHOOSER
1482
344
1624
389
HBS-year
HBS-year
2006 2007 2008 2009
0

@#$#@#$#@
# Crime

The [Swedish Crime Survey](https://www.bra.se/bra-in-english/home/crime-and-statistics/swedish-crime-survey.html) reports that 22.6% of the population were the victim of an offence against an individual (assault, threat, sexual offence, robbery, pickpocketing, sales fraud, credit card fraud, or online harassment) in 2019. Sales fraud, credit card fraud and online harassment are not crimes that would affect the reputation of an area. Of the other crimes:

  + Threats are reported by 9.2% of the population (9.5% by men, 8.9% by women)
  + Assault by 3.6% (4.6% male, 2.7% female)
  + Sexual offence by 5.6% (1.4% male, 9.4% female; but in age group 20-24, it's 4.3% male, 31.6% female)
  + Pickpocketing by 2.7% (2.6% male, 2.7% female)
  + Robbery by 1.5% (2.3% male, 0.7% female; but in age group 16-19, it's 5.9% male and in age group 20-24, 1.4% female)

Against the household, of those crimes that would affect the reputation of a neighbourhood:

  + Bicycle theft is reported by 11.4%
  + Theft from a vehicle is reported by 4.6%
  + Burglary is reported by 1.7%
  + Car theft is reported by 1.0%

These figures are for the whole of Sweden, not for Stockholm or Malmo specifically. The statistics are not broken down by ethnicity, but [Bra](https://www.bra.se) has a page dedicated to [hate crime](https://www.bra.se/bra-in-english/home/crime-and-statistics/hate-crime.html), which reports 4865 xenophobic or racially motivated hate crimes in 2018 (which could include online abuse), out of 7090 hate crimes in total that year. Of the 2225 non-racially-motivated hate crimes, 278 were antisemitic, 562 islamophobic, 292 christianophobic, and 260 were 'other' anti-religious. An [opinion piece on Al Jazeera](http://america.aljazeera.com/opinions/2014/6/sweden-refugees-racismstockholm.html) specifically refers to Husby and other areas of North Stockholm, with an anecdotal report from an "I'm not racist" interviewee who makes the reputation of the area clear. The UN Committee on the Elimination of Racial Discrimination's [Concluding observations on the combined twenty-second and twenty-third periodic reports of Sweden](https://crd.org/wp-content/uploads/2018/05/CERD-2018.pdf) (Report CERD/C/SWE/CO/22-23, dated 11 May 2018) lists a number of concerns pertaining to the high number of reported hate crimes (para. 10), presence of racist and extremist parties (para. 12), rights of the Sami people (para. 16), de facto segregation -- particularly with respect to Muslim and black populations (paras. 18 and 22), and police racial profiling (para. 24). 

Karlsson, R. (2019) [Quality of statistics regarding persons suspected of offences: A quality study of criminal statistics](https://www.bra.se/download/18.62c6cfa2166eca5d70eb93ad/1602746586925/2019_Quality_statistics_suspected_persons.pdf) Swedish National Council for Crime Prevention, Box 1386, 111 93 Stockholm (ISSN 1100-6676).

This is a short summary, but it states that an average of 178,000 people are suspected of an offence per year during the period 2004-2014. A Google search for the "population of Sweden in 2014" returned a figure of 9.645 million, which suggests 1.8% of the population are criminals. However, this figure will include offences (e.g. driving offences, fraud) unrelated to those we are interested in that might affect the reputation of an area.

# Citations

## Weather data

Anders Moberg (2021). Stockholm Historical Weather Observations -- Monthly mean air temperatures since 1756. Dataset version 3.0. Bolin Centre Database. https://doi.org/10.17043/stockholm-historical-temps-monthly-3

# ChangeLog

## 3 May 2022

### Bug fixes when writing the ODD

  1. The temperature calculation effectively added `env-y-temp` twice.
  2. Household eco education didn't happen if an intervention offered it.
  3. Household suggesting a protest to social network didn't then set their own `protesting?` flag.
  4. Interventions did not move households out or in.
  5. Interventions did not negotiate upgrades with tenants.
  6. Energy cost forumula used 100.1 / 100 instead of 110 / 100 to get 1.1 SEK per month per kWh per day
  7. Energy consumption formula _added_ no-daylight hours `(24 - daylight-hours)` to the rest of the equation rather than multiplying it.
  8. Households paid their rent twice rather than payint their energy bill. The monthly energy consumption was not accumulated, so `apartment-energy-bill` was added.
  9. `move-waiting-list` did not use lt extension
 10. `apartment-renovation-time` was initialized to 999 (should not make any difference)
 11. The workplace social network connected to any household, not just `employed?` ones.
 12. `intervention-households` did not `report results`
 13. No expenses besides rent and energy
 14. `"on-going"` and `"ongoing"` used inconsistently as `apartment-renovation-status` (now always `"on-going"`)
 15. Households could move while part of an intervention
 16. `k-per-kwh` was not used -- but clearly intended instead of 1.1 SEK (over-writes issue 6)

## 17 June 2021

### Changed

- GUI adjusted
- Moved everything to a single file to reduce interdependency risks
- Version control now uses git rather than vXX in file name

## v0.8 - 27.11.2020

--- ChangeLog temporaly suspended due to tight time constrain ---

### Added

- Added agents to house. Each agent is rapresentative of an entire household. It can be supposed to be the "gatekeeper" of the decisions of the whole family since it is likely that one figure in the household is going to lead the others. 



## v0.7.1 - 23.11.2020

### Changed

- Automatically fill boroughs stats table with information computed based on the map. Now the borough stats table is automatically filled with information retrieved from the map (e.g. the percentage of green areas, or the number of services and add them to the boroughs stats table).
	- For now it containes the percentage of green areas (the percentage of patches of type "A-pois-green"), the percentage of green mobility (the sum of the percentage of patches of type "R-cycleway" and "R-footway"), and the absolute number of services available in the borough.


## v0.7 - 20.11.2020

### Changed

- **Major change**. Agent-buildings were split into 3 different agents: apartments, activities (commercial, retail, industries, etc), and services (hospitals, kindergarten, schools, etc). This because it was becoming verbose to identify apartments, the main foucs of the model, using buildings with [building-type = "apartments"]. Plus, it is now easier and sensible to have different variables for each building type (i.e. it did not make sense to have building-rent for building of building-type = activity). 

- Changed shaped to apartments from default shape "house" to custom shape "shape_apartment", which should represent one typical apartment in a social house building.

- Only apartments have now a construction year.

- For this changelog SMARTEES Research Diary now will be SRD for convenience. This is reported among the conventions.

### Added

- Added procedure to initialise agent services' and activities' variables: *services-init-variables* and *activities-init-variables*.

- Added *apartment-size* for apartments, meaning apartment's square meters. These comes in 3 different sizes: 55m2, 75m2, 88m2. These info comes from the description of the apartments built by Svenska Bonstader in the 60s/70s. See SRD for info.

- Added (monthly) rent for apartments in *apartment-rent*. The average price before any renovation was determined to be 69.88 SEK/month per m2. Rent is computed based on the *apartment-size*.

- Adeded *apartment-energy-consumption* for the energy consumption of apartments (kWh/monthly).

- Added *apartment-energy-efficiency*, which determine the energy efficiency of the apartement. Fixed to 1 until the apartemnt is not renvoated. If renovated value equal 0.67 since it was observed an average reduction of energy consumption of about 33% in the sustainable Jarva project. See SRD on 23.11.2020 for deatils.

- Added *apartment-energy-cost* (SEK/month). This cost is computed based on the apartment's consumption and with a fixed value of 1.1 SEK/kWh. See SRD on 23.11.2020 for details.

- Added (monthly) maintenance costs for apartments in *apartment-maintenance-cost*. This cost is fixed. See SRD on 23.11.2020 for details. 

- Added apartment-total-cost. This is the (monthly) sum of the apartment energy cost and the maintenance costs. See SRD on 23.11.2020 for details.

- Added procedure * apartments-renovation-starts* and * apartments-renovation-ends*, which mark the beginning and end of the renovation. For now it just changes basic things.

- Added *apartment-renovated?* (T/F) to mark renovated building (only if renovation is finished).

- Added *apartment-renovation-time* to store the months need to be complete the renovation.

- Added *apartment-renovation-status* to mark if a building is under renovation. "NA" for non renovated; "on-going" for on-going renovation; "completed" for completed renovation

- Added procedure *apartments-update* where the apartment's variable are updated to reflect renovations or other changes (should be called every time step from the go procedure).

## v0.6.5 - 20.11.2020

### Changed

- Changed the term "dwelling(s)" with "apartment(s)" to match terms used in research and reports throghout the code (note that the changelog before this entry will keep using the term "dwelling(s)").

## v0.6.4 - 20.11.2020

### Added

- Added code to assign to each building a year of construction based on real data (see SMARTEES Research Diary on the 20.11.2020 for all info and sources). Code was inserted in procedure *world-create-buildings*, where buildings' var are initialised.

- Added code at the beginning of setup to check the size of the world. If the model is set to 300x165 (location of origin: center), it will reproduces the number of apartments ownwed by Svenska Bonstader (SB; around 5,200). See SMARTEES Research Diary for more info.

- Added procedure *random-triangular* to get a random value from a triangular distribution (courtesy of Bedham's "Tutorial on ABM").

- Added building's construction year (for all buildings, no matter the type). The year is based on triangular distribution with mode equals 1970, min 1951, max 1979. This was chosen to reflect the presence of buildings from the 50s and at the same time emphasises the Million House Programme happened between the 1965 and 1974 (see Research Diary for more info).

### Removed

- Removed procedure *world-create-buildings*. Now the setup ask patches to sprout buildings and the call the procedure *buildings-init-variables*. This is more coherent with the rest of code.

## v0.6.3 - 19.11.2020

### Removed

- Draw of GIS map was removed from the setup since it was not useful, patches reproduce GIS data well enough. Only the boundaries of the borough were left.
- Procedure *world-gis-draw* was removed since it was only used to draw boundaries once.

## v0.6.2 - 19.11.2020

### Changes

- I went back to QGIS and split the GIS datafiles into subfiles so that the code is much easier to write and read and each feature of the maps are better mapped.

- Roads are now mapped in a better way than prev versions by using *gis:intersecting*.

- Original GIS datafiles about stockholm roads containing roadways, cycleways, and footways was split into three datafiles, one for each type of road. The associated patches have *patch-type* equal to "R-roadway", "R-cycleway", and "R-footway" respectively (where "R-" means "road"). These patches have also *patch-is-road?* = TRUE.

- The same was done for areas associated with buildings. Areas type are "dwellings", "activity". The associated *patch-type" are respectively "A-dwellings", "A-activity"(where "A-" means "area"). These patches have also *patch-is-buildings-area?* = TRUE.

- Point of interests were extracted from GIS datafiles using QGIS. They were also split into two datafiles, one for green areas and for public buildings (e.g. Kindergarten, hospitals, graveyards, etc). In this case, Patches associated with pois have *patch-type* equals to "A-pois-green_areas" and "A-pois-public". These patches have also *patch-is-buildings-area?* = TRUE.

- Buildings built over patches of type "A-pois-public_buldings" feature buildings of *building-type* = "public"


### Added

- Added *glb-boroughs-stats-table-print*. Print in the output the boroughs stats table. Useful for collecting output also headless.

### Removed

- Remove procedure *buildings-init-variable*. Now buildings are created and their variables initiated in procedure *world-create-buildings*.

## v0.6.1 - 18.11.2020

### Changes

There was a semantic issue and confounding problem in constatly using the term "area/areas" for both areas as borough and the areas as patches. So, now the term borough is used thorughout the programme to refer to boroughs (e.g. Akalla, Kista, etc.), while "area" refer to patches. (Note that the term will persist in the log of the previous version).

Also, some procedures have been renamed

- Procedure *patches-areas-assign-type* and *world-create-buildings* were reviewed to match the code flow of *patches-roads-assign-type*.
- *patch-type* now has a major distinction: R- and A-type. R-type indicates patches that are roads and then then type of road (R-roadway, R-cycleway, R-footway, or R-unknown). A-type indicates patches that are areas and the type of areas (R-dwellings, R-other). Patches that are none of these type have *patch-type* = "NA".

### Added

- Added roads...

## v0.6 - 16.11.2020

### Added

- Added table extension and global var (*glb-areas-stats-table*) to store info about areas.
- Added procedure *glb-areas-stats-table-creation*. It creates the aforementioned table. Information about areas (like crime rate, percentage of foreign born, etc.) can be inserted from here.
- Since NetLogo tables can only store info in two columns, the table has a unusual format but that should simplify operation of reading/writing. Spefically, the first row stores the headers (ie the types of information): "header" -> ["social_areas_pct" "foreign_born_pct" "aut_trust"]. The subsequent rows store the area's name as keys and the associated values as a list with the same order of the headers defined above. The tables will look like this:

| header | social_areas_pct | foreign_born_pct | aut_trust |
| Akalla | 40 | 50 | 4 |
| Husby | 35 | 55 | 3 |
| Kista | 50 | 45 | 3 |

- Added procedure *glb-areas-stats-table-retrieve-value*. Query the areas stats table an return the requested value depending on the wanted type of information and the area.

- Added procedure *glb-areas-stats-table-update-values*. Write a new value into the areas stats table.

## v0.5 - 10.11.2020

Starting point of the model. After having designed and discussed a good-enough conceptual model that compromise between theory and available data, the coding of the model started. The conceptual model is available in the PowerPoint document "*District regeneration - Concept model.pptx*", slide "Conceptual model 2020.11.05 - v.1.0". The translation from the conceptual model to the NetLogo programme started from the buildings and neighborhoods (henceforth called "areas").

This model focuses on Stockholm and later will be adapated to Malmo (and possible to any other city).

### Added

- Imported and draw Stockholm GIS datafiles about neighborhood boundaries (ie "areas"), rails, roads, buildings, and point of interests (e.g. green areas). Shapefiles were retrieved by Margaret McKeen using OpenStreeMap except for the areas boundaries (stadstelar) which were retrieved by David Hales.
- The programme finds the centroids of each area and assign the corresponding area name from the GIS datafile (e.g. Akalla, Husby, etc). Labels about areas can toggled from the interface with the button "*Toggle labels*"
- Patches within the map boundaries are marked (*patch-inside-map? = TRUE*). 
- All patches inside the map -and not centroids- receive an area's name depending on the closest centroid (*patch-area-name*). 
	- Note that this leads to discrepancies between the area marked by the patches and the real area boundaries (e.g. some patches of the Husby area go behind the actual area and into Kista area). However, this was deemed acceptable given that the buildings -which are more important for the model- show less discrepancies on this same matter. 
	- Note also that this procedure requires a long time for the model to load. For this reason the visualisation monitor was reduced to small.
- Each patch reiceved a specific area type (*patch-area-type*) based on the GIS buildings datafiles (e.g. house, terrace, commercial, industry, etc.).
	- Became *patch-type* in v0.6 because "area" was semantically wrong.
- Buildings of type "dwelling" are built over patches with specific area types related to dwellings ("house" "terrace" "apartments" "residential" "semi" "detached" "semidetached_house"). All other patches with a different area type sprout a building of type "other". 
- Buildings takes the same area of the patch they are over (*building-area-name*).
- Buildings of type "dwellings" and "other" can be toggled from the map with the respective buttons from the interface.

# Conventions

This section is in line with the last version of the model you are reading. So, if conventions changes, there will no record of the changes but only the latest set conventions.

- Global variables start with the prefix "glb-" (e.g. *glb-gis-dir* is the directory of the GIS files).
- Variables starts with the agent they refer to. For instance, *patch-area-name* indicates a variable of patches; buildings-type indicates a variable of agent buildings.
- Procedures names starts with the agent or the variable they refer to as well. For instance, *patches-init-variables* indicates a procedure that initialise the variables of patches;  *glb-areas-stats-table-retrieve-value* refer to a procedure to retrieve info from the variable *glb-areas-stats-table*.
	- Note that some procedures' names can refer to specific agents. For instance, *patch-area-assign-type* refers specifically to patches of type "areas", wheares *patch-roads-assign-type* refers specifically to patches of type "road", wheares
- The first {} at the top of a procedure indicates the procedure context. The second {} is a brief commentary about the procedure.
- This changelog mention the SRD: it referes to SMARTEES Research Diary I used to keep track of everything done or thought about this model (I would suggest to read it but there are risks for your mental sanity).

# WHAT IS IT?

A model of sustainable district regeneration. The codename "Wolverine" is derived from the (wrong) English translation of the word Jarva, which refer to the area of the SMARTEES Cluster 3 Stockholm case study.


# CREDITS AND REFERENCES

Scalco, A., Polhill, G. (2020). The James Hutton Institute.

Main contact: andrea.scalco@hutton.ac.uk.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

container
false
0
Rectangle -7500403 false false 0 75 300 225
Rectangle -7500403 true true 0 75 300 225
Line -16777216 false 0 210 300 210
Line -16777216 false 0 90 300 90
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tower block
false
0
Rectangle -7500403 true true 75 30 240 285
Rectangle -16777216 true false 105 60 120 75
Rectangle -16777216 true false 150 60 165 75
Rectangle -16777216 true false 195 105 210 120
Rectangle -16777216 true false 195 60 210 75
Rectangle -16777216 true false 105 105 120 120
Rectangle -16777216 true false 150 105 165 120
Rectangle -16777216 true false 105 150 120 165
Rectangle -16777216 true false 150 150 165 165
Rectangle -16777216 true false 195 150 210 165
Rectangle -16777216 true false 105 195 120 210
Rectangle -16777216 true false 150 195 165 210
Rectangle -16777216 true false 195 195 210 210
Rectangle -16777216 true false 105 240 120 255
Rectangle -16777216 true false 150 240 165 285
Rectangle -16777216 true false 195 240 210 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>mean [apartment-energy-consumption] of apartments</metric>
    <metric>min [apartment-energy-consumption] of apartments</metric>
    <metric>max [apartment-energy-consumption] of apartments</metric>
    <metric>median [apartment-energy-consumption] of apartments</metric>
    <metric>standard-deviation [apartment-energy-consumption] of apartments</metric>
    <enumeratedValueSet variable="dwellings-per-tower-block">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-max">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dwellings-per-terrace">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-services">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-criminal">
      <value value="0.018"/>
    </enumeratedValueSet>
    <steppedValueSet variable="p-renovate" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="next-renovation">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-start-year">
      <value value="1850"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-avg">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-energy-efficiency-decay-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartments-in-houses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-city-reach">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-activities">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-neighbour-reach">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="renovation-time-per-apartment">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-household-habits-eco">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-ethnicities">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-min">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-climate-scenarios">
      <value value="&quot;RCP8.5&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-end-year">
      <value value="1950"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-sd">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="videos" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/video-P" p-renovate "-" ticks ".png")</go>
    <timeLimit steps="3650"/>
    <metric>mean [apartment-energy-consumption] of apartments</metric>
    <metric>min [apartment-energy-consumption] of apartments</metric>
    <metric>max [apartment-energy-consumption] of apartments</metric>
    <metric>median [apartment-energy-consumption] of apartments</metric>
    <metric>standard-deviation [apartment-energy-consumption] of apartments</metric>
    <enumeratedValueSet variable="dwellings-per-tower-block">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-max">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dwellings-per-terrace">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-services">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-criminal">
      <value value="0.018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-renovate">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="next-renovation">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-start-year">
      <value value="1850"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-avg">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-energy-efficiency-decay-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartments-in-houses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-city-reach">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-activities">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-neighbour-reach">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="renovation-time-per-apartment">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-household-habits-eco">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-ethnicities">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-min">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-climate-scenarios">
      <value value="&quot;RCP8.5&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-end-year">
      <value value="1950"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-sd">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-P0.8" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/video-P" p-renovate "-" ticks ".png")</go>
    <timeLimit steps="3650"/>
    <metric>mean [apartment-energy-consumption] of apartments</metric>
    <metric>min [apartment-energy-consumption] of apartments</metric>
    <metric>max [apartment-energy-consumption] of apartments</metric>
    <metric>median [apartment-energy-consumption] of apartments</metric>
    <metric>standard-deviation [apartment-energy-consumption] of apartments</metric>
    <enumeratedValueSet variable="dwellings-per-tower-block">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-max">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dwellings-per-terrace">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-services">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-criminal">
      <value value="0.018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-renovate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="next-renovation">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-start-year">
      <value value="1850"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-avg">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-energy-efficiency-decay-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartments-in-houses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-city-reach">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-activities">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-neighbour-reach">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="renovation-time-per-apartment">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-household-habits-eco">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-ethnicities">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-min">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-climate-scenarios">
      <value value="&quot;RCP8.5&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-end-year">
      <value value="1950"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-sd">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-P0.2+0.4" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/video-P" p-renovate "-" ticks ".png")</go>
    <timeLimit steps="3650"/>
    <metric>mean [apartment-energy-consumption] of apartments</metric>
    <metric>min [apartment-energy-consumption] of apartments</metric>
    <metric>max [apartment-energy-consumption] of apartments</metric>
    <metric>median [apartment-energy-consumption] of apartments</metric>
    <metric>standard-deviation [apartment-energy-consumption] of apartments</metric>
    <enumeratedValueSet variable="dwellings-per-tower-block">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-max">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dwellings-per-terrace">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-services">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-criminal">
      <value value="0.018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-renovate">
      <value value="0.2"/>
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="next-renovation">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-start-year">
      <value value="1850"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-avg">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-energy-efficiency-decay-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartments-in-houses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-city-reach">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-activities">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-neighbour-reach">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="renovation-time-per-apartment">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-household-habits-eco">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-ethnicities">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily-min">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-climate-scenarios">
      <value value="&quot;RCP8.5&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-calibration-end-year">
      <value value="1950"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="apartment-maintenance-cost-sd">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
