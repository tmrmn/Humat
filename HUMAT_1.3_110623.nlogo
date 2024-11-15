globals [ setup? ]

breed [HUMATS HUMAT]

HUMATS-own [

  percentA
  percentB
  #same-choice ;  number of alters with the same choice in ego network as perceived by ego

  chosen ; alternative chosen by HUMAT
  aspiration-level ; the aspirational attribute of the HUMAT designates the extent to which copying this HUMAT's choice is appealing to other HUMATS: an objective value used for the calculation of the relative aspiration level in an interaction between two HUMATS; constant throughout the simulation; in the architecture initiated randomly < 0 ; 1 >

  ;;;dissonance-related variables;;;

 ;variables calculated for all CAs;
  experiential-importance
  social-importance
  values-importance

  experiential-satisfaction-A
  social-satisfaction-A
  values-satisfaction-A
  experiential-satisfaction-B
  social-satisfaction-B
  values-satisfaction-B

  experiential-evaluation ; evaluation of selected option
  social-evaluation ; evaluation of selected option
  values-evaluation ; evaluation of selected option
  experiential-evaluation-A ; evaluation of A (choice alternative i) with respect to experiential group of needs for HUMAT j <-1;1>
  social-evaluation-A ; evaluation of A (choice alternative i) with respect to social group of needs for HUMAT j <-1;1>
  values-evaluation-A ; evaluation of A (choice alternative i) with respect to values for HUMAT j <-1;1>
  experiential-evaluation-B ; evaluation of B (choice alternative ~i) with respect to experiential group of needs for HUMAT j <-1;1>
  social-evaluation-B ; evaluation of B (choice alternative ~i) with respect to social group of needs for HUMAT j <-1;1>
  values-evaluation-B ; evaluation of B (choice alternative ~i) with respect to values for HUMAT j <-1;1>
  evaluations-list-A
  evaluations-list-B

  satisfaction-A
  satisfaction-B
  satisfaction ; satisfaction from a chosen alternative; either satisfaction-A or satisfaction-B

  dissatisfying-A ; the sum of dissatisfying evaluations of A <0;1,5>
  satisfying-A ; the sum of satisfying evaluations of A over three groups of needs <0;1,5>
  dissatisfying-B ; the sum of dissatisfying evaluations of B over three groups of needs <0;1,5>
  satisfying-B ; the sum of satisfying evaluations of B over three groups of needs <0;1,5>

  dissonance-A ; the level of cognitive dissonance a choice alternative i (A) evokes in HUMAT j at time tn [Dij tn] <0;1>
  dissonance-B ; the level of cognitive dissonance a choice alternative i (B) evokes in HUMAT j at time tn [Dij tn] <0;1>
  dissonance-tolerance ; individual difference in tolerating dissonances before they evoke dissonance reduction strategies [Tj] normal trunc distribution with mean = 0.5, sd = 0.14 trunc to values <0;1>, this is the threshold determining if a reduction strategy is forgetting/distraction or if action has to be taken
  dissonance-strength-A ; individually perceived strength of cognitive dissonance a choice alternative i (A) evokes in HUMAT j at time tn [Fij tn]; F because it's a fraction of maximum dissonance HUMAT j can possibly experience <0;1>
  dissonance-strength-B ; individually perceived strength of cognitive dissonance a choice alternative i (B) evokes in HUMAT j at time tn [Fij tn]; F because it's a fraction of maximum dissonance HUMAT j can possibly experience <0;1>
  dissonance-strength ; individually perceived strength of cognitive dissonance a chosen alternative evokes in HUMAT j at time tn [Fij tn]; either dissonance-strenght-A or dissonance-strength-B, depending on chosen alternative

  ;variables only calculated for the chosen alternative, not for all CAs;
  dilemma-social? ; the existence of a dilemma that a chosen alternative i evokes in HUMAT j at time tn [Dij tn = {0,1}, where 0 donotes no dilemma and 1 denotes existence of dilemma]
  dilemma-non-social?

  ;;;alter-representation variables;;;
  alter-representation-list
  inquiring-list
  signaling-list
  inquired-humat  ; the list belongs to ego and contains information about the alter who the ego inquires with
  inquiring-humat ; the list belongs to an inquired alter and contains information about the ego who is inquiring
  signaled-humat  ; the list belongs to ego and contains information about the alter who the ego signals to
  signaling-humat ; the list belongs to a signaled alter and contains information about the ego who is signaling

  inquiring? ; boolean positive [1] if the ego is inquiring at a given tick
  #inquiring ;the number of times humat inquired with alters
  #inquired ; the number of times humat was inquired with by egos
  signaling? ; boolean positive [1] if the ego is signaling at a given tick
  #signaling ; the number of times humat signaled to alters
  #signaled ; the number of times humat was signaled to
]


;;;;;;;;;;;;;;;;;;
;;; Procedures ;;;
;;;;;;;;;;;;;;;;;;


to Setup
  clear-all
  Create-Agents
  Create-Networks
  Setup-HUMATS
  reset-ticks
  update-plots
end


to Go
 Signal-or-Inquire
 Set-Dissonances
 tick
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;


to Create-Agents
  ask patches [set pcolor white]
  create-HUMATS N-HUMATS
  [
    set size 4
    set shape "person"
    fd random 40
    set aspiration-level random-float 1
  ]
end


to Create-Networks
 ; each HUMAT creates social links with 20% of alters who are close to it (within a distance of 35)
 ; each HUMAT has at least one link with an alter
  ask HUMATS [
    let topological-neighbours other HUMATS with [distance myself <= 35]
    let #topological-neighbours count topological-neighbours
    create-links-with n-of (0.2 * #topological-neighbours) topological-neighbours [set color 48]
    if count link-neighbors = 0 [create-link-with min-one-of other HUMATS [distance myself] [set color 48]]
  ]
end


to Setup-Humats
  Set-Non-Social-Motives
  Set-Basic-Choice ; set chosen on the basis of non-social motives (experiential and values)
  Set-Initial-Choice ; set chosen on the basis of all 3 motives
  Set-Alter-Representations
  Set-Dissonances
  set setup? 1 ;setup is over humats will build habits from now on
end


to Set-Non-Social-Motives
  ask HUMATS [
    ; set dissonance tolerance
    set dissonance-tolerance Random-Normal-Trunc 0.5 0.14 0 1 ; set dissonance tolerance

    ; set motive importances
    set experiential-importance random-normal-trunc 0.5 0.14 0 1
    set social-importance random-normal-trunc 0.5 0.14 0 1
    set values-importance random-normal-trunc 0.5 0.14 0 1

    ; set initial satisfactions for CA A and CA B ; excluding social dimension
    ; A
    if A-experiential-satisfaction = "heavily left-skewed"   [set experiential-satisfaction-A normalized-min-max random-beta 12 4 0 1 -1 1]
    if A-experiential-satisfaction = "slightly left-skewed"  [set experiential-satisfaction-A normalized-min-max random-beta 8 4 0 1 -1 1]
    if A-experiential-satisfaction = "symmetric"             [set experiential-satisfaction-A normalized-min-max random-beta 4 4 0 1 -1 1]
    if A-experiential-satisfaction = "slightly right-skewed" [set experiential-satisfaction-A normalized-min-max random-beta 4 8 0 1 -1 1]
    if A-experiential-satisfaction = "heavily right-skewed"  [set experiential-satisfaction-A normalized-min-max random-beta 4 12 0 1 -1 1]

    if A-values-satisfaction = "heavily left-skewed"   [set values-satisfaction-A normalized-min-max random-beta 12 4 0 1 -1 1]
    if A-values-satisfaction = "slightly left-skewed"  [set values-satisfaction-A normalized-min-max random-beta 8 4 0 1 -1 1]
    if A-values-satisfaction = "symmetric"             [set values-satisfaction-A normalized-min-max random-beta 4 4 0 1 -1 1]
    if A-values-satisfaction = "slightly right-skewed" [set values-satisfaction-A normalized-min-max random-beta 4 8 0 1 -1 1]
    if A-values-satisfaction = "heavily right-skewed"  [set values-satisfaction-A normalized-min-max random-beta 4 12 0 1 -1 1]

    ; B
    if B-experiential-satisfaction = "heavily left-skewed"   [set experiential-satisfaction-B normalized-min-max random-beta 12 4 0 1 -1 1]
    if B-experiential-satisfaction = "slightly left-skewed"  [set experiential-satisfaction-B normalized-min-max random-beta 8 4 0 1 -1 1]
    if B-experiential-satisfaction = "symmetric"             [set experiential-satisfaction-B normalized-min-max random-beta 4 4 0 1 -1 1]
    if B-experiential-satisfaction = "slightly right-skewed" [set experiential-satisfaction-B normalized-min-max random-beta 4 8 0 1 -1 1]
    if B-experiential-satisfaction = "heavily right-skewed"  [set experiential-satisfaction-B normalized-min-max random-beta 4 12 0 1 -1 1]

    if B-values-satisfaction = "heavily left-skewed"   [set values-satisfaction-B normalized-min-max random-beta 12 4 0 1 -1 1]
    if B-values-satisfaction = "slightly left-skewed"  [set values-satisfaction-B normalized-min-max random-beta 8 4 0 1 -1 1]
    if B-values-satisfaction = "symmetric"             [set values-satisfaction-B normalized-min-max random-beta 4 4 0 1 -1 1]
    if B-values-satisfaction = "slightly right-skewed" [set values-satisfaction-B normalized-min-max random-beta 4 8 0 1 -1 1]
    if B-values-satisfaction = "heavily right-skewed"  [set values-satisfaction-B normalized-min-max random-beta 4 12 0 1 -1 1]

    Update-Motive-Evaluations
  ]
end


to Set-Basic-Choice
  ask HUMATS [
    ; set satisfactions from CAs ; excluding social dimension
    set satisfaction-A (experiential-evaluation-A + values-evaluation-A) / 2
    set satisfaction-B (experiential-evaluation-B + values-evaluation-B) / 2

    ; make basic choice on the basis of experiential needs and values; if similar satisfactions from both CAs, choose randomly
    (ifelse
      satisfaction-A < satisfaction-B
      [set chosen "B" set satisfaction satisfaction-B]
      satisfaction-A = satisfaction-B
      [set chosen one-of (list "A" "B")
        ifelse chosen = "A"
        [set satisfaction satisfaction-A]
        [set satisfaction satisfaction-B]
      ]
      [set chosen "A" set satisfaction satisfaction-A]
    )
  ]
end


to Set-Initial-Choice
  ask HUMATS [
    Set-Representation-List ; go through alter-representation-list and count the alters, who behave similarily
    Set-Social-Motive ; set social dimension: social satisfaction from CAs, evaluations of CAs
    Identify-Dilemmas ; update dilemmas
  ]
  Choose-Alternative
end


to Set-Representation-List ; HUMAT-oriented
  set alter-representation-list []
  set #same-choice 0
  ; create alter representation lists for each alter
  ; HUMAT assumes perfect information on alters choic
  foreach sort link-neighbors [x ->
    let working-list ( list
      [who] of x                              ;item 0 who
      0                                       ;item 1 inquired? 0 for not inquired with, 1 for inquired with already
      0                                       ;item 2 signaled? 0 for not signaled to, 1 for signaled to already
      [chosen] of x                           ;item 3 chosen alternative
      same-CA? chosen [chosen] of x           ;item 4 1 for same chosen; 0 for different chosen alternative; used for inquiring
      ifelse-value (same-CA? chosen [chosen] of x  = 1) [0] [1] ; item 5  1 for different chosen alternative and 0 for same chosen alterative; used for signaling - coding is the other way around for the purpose of using the same reporter for sorting lists as in the case of inquiring
      0                                       ;item 6 [experiential-importance] of x
      0                                       ;item 7 [social-importance] of x
      0                                       ;item 8 [values-importance] of x
      0                                       ;item 9 [experiential-satisfaction-A] of x
      0                                       ;item 10 [social-satisfaction-A] of x
      0                                       ;item 11 [values-satisfaction-A] of x
      0                                       ;item 12 [experiential-satisfaction-B] of x
      0                                       ;item 13 [social-satisfaction-B] of x
      0                                       ;item 14 [values-satisfaction-B] of x
      0                                       ;item 15 similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego
      0                                       ;item 16 simiarity-A-values-importance
      0                                       ;item 17 similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego
      0                                       ;item 18 similarity-B-experiential-importance
      0                                       ;item 19 relative-aspiration-influenced-ego - relative social appeal/status (aspiration characteristic) in case of inquiring
      0                                       ;item 20 relative-aspiration-influenced-alter - relative social appeal/status (aspiration characteristic) in case of signaling
      0                                       ;item 21 inquiring-persuasion-A-experiential
      0                                       ;item 22 inquiring-persuasion-A-values
      0                                       ;item 23 inquiring-persuasion-B-experiential
      0                                       ;item 24 inquiring-persuasion-B-values
      0                                       ;item 25 signaling-persuasion-A-experiential
      0                                       ;item 26 signaling-persuasion-A-values
      0                                       ;item 27 signaling-persuasion-B-experiential
      0                                       ;item 28 signaling-persuasion-B-values
      0                                       ;item 29 inquiring-persuasion
      0                                       ;item 30 signaling-persuasion
    )
    set alter-representation-list lput working-list alter-representation-list
    set #same-choice #same-choice + item 4 working-list
  ]
end


to Set-Alter-Representations
 ask HUMATS [
    Set-Representation-List

    ; inquiring-list sorted:
     ;(1) ascendingly by inquired? (not inquired with first),
     ;(2) descendingly by same-CA? (same chosen alternative first),
     ;(3) descendingly by persuasion (strongest persuasion first).
    set inquiring-list sort-list alter-representation-list 1 4 29

    ; signaling-list sorted:
     ;(1) ascendingly by signaled? (not signaled to first),
     ;(2) descendingly by not the same-CA? (different chosen alternative first),
     ;(3) descendingly by gullibility (the most easily persuaded first).
    set signaling-list sort-list alter-representation-list 2 5 30

    set inquired-humat []
    set inquiring-humat []
    set signaled-humat []
    set signaling-humat []
  ]
end


;;;;;;;;;;;;;;;;;;;;;
;;; Go Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;


to Signal-or-Inquire
  ask HUMATS [
    set signaling? 0
    set inquiring? 0
    if (dissonance-strength > 0) [
      (ifelse
        dilemma-social? = 1 and dilemma-non-social? = 1 [ifelse (random-float 1 > .5) [Signal][Inquire]] ; if both dilemmas random Signal or Inquire
        dilemma-social? = 1 [Signal] ; if dissonance above tolerance threshold and social dilemma -> Signal
        dilemma-non-social? = 1 [Inquire] ; if dissonance above tolerance threshold and non-social dilemma -> Inquire
        []); else do nothing
    ]
  ]
end


to Signal ; HUMAT-oriented
  ;signaling strategy - spread information in social network to reduce cognitive dissonance via altering ALTERs' knowledge structures
  ;during signaling information flows uni-directionally from the ego, who was giving advice to the alter, who was made to listed

  ;signaled-humat - the list belongs to ego and contains information about the alter who the ego signals to
  ;signaling-humat - the list belongs to a signaled alter and contains information about the ego who is signaling

    set signaled-humat item 0 signaling-list ;ego's representation of an alter as a temporary list

    ;update alter's representation of ego
    ask HUMAT item 0 signaled-humat [
        set #signaled #signaled + 1
        foreach alter-representation-list [ x -> if item 0 x = [who] of myself [set signaling-humat item position x alter-representation-list alter-representation-list]]
        set signaling-humat replace-item 3  signaling-humat [chosen] of myself
        set signaling-humat replace-item 4  signaling-humat same-CA? chosen [chosen] of myself
        set signaling-humat replace-item 5  signaling-humat ifelse-value (same-CA? chosen [chosen] of myself  = 1) [0] [1]
        set signaling-humat replace-item 6  signaling-humat [experiential-importance] of myself
        set signaling-humat replace-item 7  signaling-humat [social-importance] of myself
        set signaling-humat replace-item 8  signaling-humat [values-importance] of myself
        set signaling-humat replace-item 9  signaling-humat [experiential-satisfaction-A] of myself
        set signaling-humat replace-item 10 signaling-humat [social-satisfaction-A] of myself
        set signaling-humat replace-item 11 signaling-humat [values-satisfaction-A] of myself
        set signaling-humat replace-item 12 signaling-humat [experiential-satisfaction-B] of myself
        set signaling-humat replace-item 13 signaling-humat [social-satisfaction-B] of myself
        set signaling-humat replace-item 14 signaling-humat [values-satisfaction-B] of myself

        ; need similarity (same values for inquiring and signaling)
        set signaling-humat replace-item 15 signaling-humat need-similarity experiential-evaluation-A [experiential-evaluation-A] of myself experiential-importance [experiential-importance] of myself ;similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego[experiential-satisfaction-A] of humat item 0 signaled-humat
        set signaling-humat replace-item 16 signaling-humat need-similarity values-evaluation-A [values-evaluation-A] of myself values-importance [values-importance] of myself
        set signaling-humat replace-item 17 signaling-humat need-similarity experiential-evaluation-B [experiential-evaluation-B] of myself experiential-importance [experiential-importance] of myself ;similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego
        set signaling-humat replace-item 18 signaling-humat need-similarity values-evaluation-B [values-evaluation-B] of myself values-importance [values-importance] of myself                             ;similarity-B-experiential-importance

        ; relative aspiration is not symmetric (different values for inquiring and signaling)
        set signaling-humat replace-item 20 signaling-humat relative-aspiration [aspiration-level] of myself aspiration-level ; relative social appeal/status (aspiration characteristic) in case of signaling

        ; persuasion is a multiplication of need-similatiry and relative-aspiration, and is not symmetric (needs different values for inquiring and signaling)
        set signaling-humat replace-item 25 signaling-humat (item 15 signaling-humat * item 20 signaling-humat) ; signaling-persuasion-experiential-A = relative social appeal/status * similarity-A-experiential (similarity of needs activated by a CA)
        set signaling-humat replace-item 26 signaling-humat (item 16 signaling-humat * item 20 signaling-humat) ; signaling-persuasion-values-A
        set signaling-humat replace-item 27 signaling-humat (item 17 signaling-humat * item 20 signaling-humat) ; signaling-persuasion-experiential-B
        set signaling-humat replace-item 28 signaling-humat (item 18 signaling-humat * item 20 signaling-humat) ; signaling-persuasion-values-B

        ; seting new experiential and values satisfaction
        set experiential-satisfaction-A new-need-satisfaction-signaling experiential-satisfaction-A 25
        set values-satisfaction-A new-need-satisfaction-signaling values-satisfaction-A 26
        set experiential-satisfaction-B new-need-satisfaction-signaling experiential-satisfaction-B 27
        set values-satisfaction-B new-need-satisfaction-signaling values-satisfaction-B 28

        ; update alter's representation of the inquiring ego
        ; long-term memory - please note that alter's representation of the signaling ego only influences the update on social satisfaction, storing information other than about the CA (items 3, 4 and 5) does not influence anything
        foreach alter-representation-list [x -> if item 0 x = [who] of myself [set alter-representation-list replace-item position x alter-representation-list alter-representation-list signaling-humat]]

        Update-Motive-Evaluations
        Update-Dissonances
        Choose-Alternative
      ]

    ; update ego's representation of the signaled alter
    ; please note that alter's representation of the signaled alter is only updated to the extent of the alter's new decision about the CA (items 3,4,5)
    set signaled-humat replace-item  2 signaled-humat 1 ;representing the fact that alter was signaled to
    set signaled-humat replace-item  3 signaled-humat [chosen] of humat item 0 signaled-humat
    set signaled-humat replace-item  4 signaled-humat same-CA? chosen [chosen] of humat item 0 signaled-humat
    set signaled-humat replace-item  5 signaled-humat ifelse-value (same-CA? chosen [chosen] of humat item 0 signaled-humat = 1) [0] [1]
    set signaled-humat replace-item 30 signaled-humat (item 25 [signaling-humat] of humat item 0 signaled-humat + item 26 [signaling-humat] of humat item 0 signaled-humat + item 27 [signaling-humat] of humat item 0 signaled-humat + item 28 [signaling-humat] of humat item 0 signaled-humat) ; gullibility (the willingness to be persuaded by the ego) of the alter is stores as the ego representation and is used later for sorting the signaling-list

   ; update signaling-list with new information about signaled humat
    set signaling-list replace-item 0 signaling-list signaled-humat

    ;update alter-representation-list by replacing the old representation (of alter the ego signaled to) with a new representation that has accurate knowledge about alters action and status of alteady having been signaled to
    foreach alter-representation-list [x -> if item 0 x = item 0 item 0 signaling-list [set alter-representation-list replace-item position x alter-representation-list alter-representation-list item 0 signaling-list]]

    ; signaling-list sorted:
     ; (1) ascendingly by signaled? (not signaled to first),
     ; (2) descendingly by not the same-CA? (different chosen alternative first), and
     ; (3) descendingly by gullibility (the most easily persuaded first; sum of aspiration*similarity over experiential and values for both CAs; please note that ego will signal to all alters in its social network and then will focus on the most easily persuaded until that one changes its mind)
    set signaling-list sort-list alter-representation-list 2 5 30

    set signaling? 1
    set #signaling #signaling + 1

    Update-Dissonances
    Choose-Alternative
end


to Inquire ; HUMAT-oriented
  ;inquire strategy - seek information in social network to reduce cognitive dissonance via altering EGOs' knowledge structures
  ;during inquiring information flows uni-directionally from the alter, who was giving advice to the ego, who was asking for advice

  ;update ego's representation of the inquired alter
  set inquiring? 1
  set #inquiring #inquiring + inquiring?
  set inquired-humat item 0 inquiring-list
  set inquired-humat replace-item 1 inquired-humat 1
  set inquired-humat replace-item 6 inquired-humat [experiential-importance] of humat item 0 inquired-humat
  set inquired-humat replace-item 7 inquired-humat [social-importance] of humat item 0 inquired-humat
  set inquired-humat replace-item 8 inquired-humat [values-importance] of humat item 0 inquired-humat
  set inquired-humat replace-item 9 inquired-humat [experiential-satisfaction-A] of humat item 0 inquired-humat
  set inquired-humat replace-item 10 inquired-humat [social-satisfaction-A] of humat item 0 inquired-humat
  set inquired-humat replace-item 11 inquired-humat [values-satisfaction-A] of humat item 0 inquired-humat
  set inquired-humat replace-item 12 inquired-humat [experiential-satisfaction-B] of humat item 0 inquired-humat
  set inquired-humat replace-item 13 inquired-humat [social-satisfaction-B] of humat item 0 inquired-humat
  set inquired-humat replace-item 14 inquired-humat [values-satisfaction-B] of humat item 0 inquired-humat

  ; need-similarity is symmetric - if ego influences alter to the degree of 40% (max), alter also influences ego to the degree of 40%
  set inquired-humat replace-item 15 inquired-humat need-similarity experiential-evaluation-A [experiential-evaluation-A] of humat item 0 inquired-humat experiential-importance [experiential-importance] of humat item 0 inquired-humat ;similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego[experiential-satisfaction-A] of humat item 0 inquired-humat
  set inquired-humat replace-item 16 inquired-humat need-similarity values-evaluation-A [values-evaluation-A] of humat item 0 inquired-humat values-importance [values-importance] of humat item 0 inquired-humat
  set inquired-humat replace-item 17 inquired-humat need-similarity experiential-evaluation-B [experiential-evaluation-B] of humat item 0 inquired-humat experiential-importance [experiential-importance] of humat item 0 inquired-humat ;similarity-A-experiential-importance - similarity between he importance of needs; only > 0 if the given CA satisfies that group of needs in a similar direction for the alter and for the ego
  set inquired-humat replace-item 18 inquired-humat need-similarity values-evaluation-B [values-evaluation-B] of humat item 0 inquired-humat values-importance [values-importance] of humat item 0 inquired-humat                                       ;similarity-B-experiential-importance

  ; relative-aspiration is not symmetric
  set inquired-humat replace-item 19 inquired-humat relative-aspiration aspiration-level [aspiration-level] of humat item 0 inquired-humat         ; relative social appeal/status (aspiration characteristic) in case of inquiring

  ; persuasion is a multiplication of need-similatiry and relative-aspiration, and is not symmetric (different values for inquiring and signaling)
  set inquired-humat replace-item 21 inquired-humat (item 15 inquired-humat * item 19 inquired-humat) ; inquiring-persuasion-experiential-A = relative social appeal/status * similarity-A-experiential (similarity of needs activated by a CA)
  set inquired-humat replace-item 22 inquired-humat (item 16 inquired-humat * item 19 inquired-humat) ; inquiring-persuasion-values-A
  set inquired-humat replace-item 23 inquired-humat (item 17 inquired-humat * item 19 inquired-humat) ; inquiring-persuasion-experiential-B
  set inquired-humat replace-item 24 inquired-humat (item 18 inquired-humat * item 19 inquired-humat) ; inquiring-persuasion-values-B
  set inquired-humat replace-item 29 inquired-humat (item 21 inquired-humat + item 22 inquired-humat + item 23 inquired-humat + item 24 inquired-humat) ; inquiring persuasion = sum of inquiring persuasions


  ;update satisfactions
  set experiential-satisfaction-A new-need-satisfaction-inquiring experiential-satisfaction-A 21 9
  set values-satisfaction-A new-need-satisfaction-inquiring values-satisfaction-A 22 11
  set experiential-satisfaction-B new-need-satisfaction-inquiring experiential-satisfaction-B 23 12
  set values-satisfaction-B new-need-satisfaction-inquiring values-satisfaction-B 24 14

  Update-Motive-Evaluations
  Update-Dissonances
  Choose-Alternative

  ; update alter's representation of the inquiring ego
  ; please note that alter's representation of the inquiring ego is only updated to the extent of the ego's new decision about the CA (items 3,4,5)
  ask HUMAT item 0 inquired-humat [
    foreach alter-representation-list [ x -> if item 0 x = [who] of myself [set inquiring-humat item position x alter-representation-list alter-representation-list]]
    set inquiring-humat replace-item 3 inquiring-humat [chosen] of myself
    set inquiring-humat replace-item 4 inquiring-humat same-CA? chosen [chosen] of myself
    set inquiring-humat replace-item 5 inquiring-humat ifelse-value (same-CA? chosen [chosen] of myself  = 1) [0] [1]
    foreach alter-representation-list [ x -> if item 0 x = [who] of myself [set alter-representation-list replace-item position x alter-representation-list alter-representation-list inquiring-humat]]
    set #inquired #inquired + 1

    Update-Dissonances
    Choose-Alternative
  ]

  ;update inquiring-list
  set inquiring-list replace-item 0 inquiring-list inquired-humat

  ;update alter-representation-list by replacing the old representation (of alter the ego inquired with) with a new representation that has accurate knowledge about alters action, motives and status of alteady having been inquired with
  foreach alter-representation-list [x -> if item 0 x = item 0 item 0 inquiring-list [set alter-representation-list replace-item position x alter-representation-list alter-representation-list item 0 inquiring-list]]

  ; inquiring-list sorted:
  ;(1) ascendingly by inquired? (not inquired with first),
  ;(2) descendingly by same-CA? (same chosen alternative first),
  ;(3) descendingly by persuasion (strongest persuasion first).
  set inquiring-list sort-list alter-representation-list 1 4 29
end


to Set-Dissonances
  ask HUMATS [
    Update-Dissonances
    Set-Dissonance-Strength
  ]
end


to Update-Dissonances ; HUMAT-oriented
  Set-Social-Motive ; Set-CA-Evaluations-n-Dissonance-Strengths
  Identify-Dilemmas ; Calculating dilemmas
end


to Set-Dissonance-Strength ; HUMAT-oriented
  ; set the dissonance strengths for choice A and B and color the HUMATS
  ifelse chosen = "A"
    [
      set dissonance-strength dissonance-strength-A
      set color lime + Shading dissonance-strength-A
    ]
    [
      set dissonance-strength dissonance-strength-B
      set color magenta + Shading dissonance-strength-B
    ]
end


to Set-Social-Motive ; HUMAT-oriented

  ; go through alter-representation-list and count the alters, who behave similarily
  let #alters length alter-representation-list

 ; update same-choice after it changed during signalling or inquiring
  set #same-choice sum map [ i -> item 4 i ] alter-representation-list
  ifelse chosen  = "A" [
    set percentA #same-choice / #alters
    set percentB 1 - percentA
  ]
  [
    set percentB #same-choice / #alters
    set percentA 1 - percentB
  ]
  ; set social dimension: social satisfaction from CAs, evaluations of CAs
  set social-satisfaction-A normalized-min-max percentA 0 1 -1 1 ; if less than 50% of alters choose A , A becomes dissatisfying (social-satisfaction-A < 0)
  set social-satisfaction-B normalized-min-max percentB 0 1 -1 1
  set social-evaluation-A social-importance * social-satisfaction-A
  set social-evaluation-B social-importance * social-satisfaction-B

  set evaluations-list-A (list (experiential-evaluation-A) (social-evaluation-A) (values-evaluation-A))
  set evaluations-list-B (list (experiential-evaluation-B) (social-evaluation-B) (values-evaluation-B))

  ; set final satisfactions from CAs at setup stage
  set satisfaction-A (experiential-evaluation-A + social-evaluation-A + values-evaluation-A) / 3
  set satisfaction-B (experiential-evaluation-B + social-evaluation-B + values-evaluation-B) / 3

  ; calculate cognitive dissonances for CAs (A and B)
  ; dis-satisfying-status-CA [evaluations-list-CA]
  set dissatisfying-A dissatisfying-status-CA evaluations-list-A
  set satisfying-A satisfying-status-CA evaluations-list-A
  set dissatisfying-B dissatisfying-status-CA evaluations-list-B
  set satisfying-B satisfying-status-CA evaluations-list-B

  set dissonance-A dissonance-status satisfying-A dissatisfying-A
  set dissonance-B dissonance-status satisfying-B dissatisfying-B

  ; calculating the need for dissonance reduction - a CA invokes the need to reduce dissonance if the level of dissonance for CA exceeds the dissonance-threshold
  set dissonance-strength-A (dissonance-A - dissonance-tolerance) / (1 - dissonance-tolerance)
  if dissonance-strength-A < 0 [set dissonance-strength-A 0] ; if the dissonance level a choice alternative i (A) [Dij tn] does not exceed the individual tolerance threshold of HUMAT j [Tj], HUMAT j does not experience any dissonance: [Dij tn] < [Tj] -> [Fij tn] = 0
  set dissonance-strength-B (dissonance-B - dissonance-tolerance) / (1 - dissonance-tolerance)
  if dissonance-strength-B < 0 [set dissonance-strength-B 0]
end


to Identify-Dilemmas ; HUMAT-oriented
  ; social dilemma occurs when an agent is socially dissatisfied with the fraction of ego network that chooses the same alternative (negative evaluation of the social need) and at least one of the other motives is evaluated positively
  ; non-social dilemma occurs when agent is socially satisfied and at least one of the other motives is evaluated negatively
  let list-negative-evaluations-motives frequency false (list (experiential-evaluation >= 0) (values-evaluation >= 0)) ; count number of falses
  set dilemma-social? (ifelse-value (social-evaluation < 0 and list-negative-evaluations-motives < 2 ) [1][0]) ; social negative and at leat one positive
  set dilemma-non-social? (ifelse-value (social-evaluation >= 0 and list-negative-evaluations-motives > 0) [1][0]) ; social positive and at leat one negative
end


to Choose-Alternative
 ; The CA comparison dimensions include:
 ; 1) overall satisfaction - preference for more satistying, if similarly satisfying (+/- 0.2 = 10% of the theoretical satisfaction range <-1;1>), then
 ; 2) dissonance level - preference for less dissonant, if similarily dissonant (+/- 0.1 = 10% of the theoretical dissonance range <0;1>), then
 ; 3) satisfaction on experiential need - preference for more satisfying, if similarly satisfying on experiantial need (+/- 0.2 = 10% of the theoretical experiantial satisfaction range <-1;1>). then
 ; If alternatives sufficiently similar choose random at during setup and choose habit in go procedure

 ask HUMATS [
    (ifelse further-comparison-needed? satisfaction-A satisfaction-B 2 [Compare-Dissonances]
    [ifelse satisfaction-A > satisfaction-B
      [set-chosen-A]
      [set-chosen-B]]
    )
  ]
end


to Compare-Dissonances ; HUMAT-oriented
  (ifelse further-comparison-needed? dissonance-A dissonance-B 1 [Compare-Experiential-Needs]
   [ifelse dissonance-A < dissonance-B
     [set-chosen-A]
     [set-chosen-B]]
  )
end


to Compare-Experiential-Needs ; HUMAT-oriented
  (ifelse further-comparison-needed?  experiential-satisfaction-A  experiential-satisfaction-B 2 [Choose-Habit]
   [ifelse  experiential-satisfaction-A >  experiential-satisfaction-B
     [set-chosen-A]
     [set-chosen-B]]
  )
end


to Choose-Habit ; HUMAT-oriented
  if setup? = 0 ;choose random in the setup procedure
  [
   set chosen one-of (list "A" "B")
   ifelse (chosen = "A") [Set-Chosen-A] [Set-Chosen-B]
  ]
 ; otherwise built up a habit
end


to Set-Chosen-A ; update evaluations for choice A ; HUMAT-oriented
  set chosen "A"
  set satisfaction satisfaction-A
  set experiential-evaluation experiential-evaluation-A
  set social-evaluation social-evaluation-A
  set values-evaluation values-evaluation-A
end


to Set-Chosen-B ; update evaluations for choice B ; HUMAT-oriented
  set chosen "B"
  set satisfaction satisfaction-B
  set experiential-evaluation experiential-evaluation-B
  set social-evaluation social-evaluation-B
  set values-evaluation values-evaluation-B
end


to Update-Motive-Evaluations ; HUMAT-oriented (does not update social)
  ; set evaluations = importances * satisfactions ; excluding social dimension
  ; A
  set experiential-evaluation-A experiential-importance * experiential-satisfaction-A
  set values-evaluation-A values-importance * values-satisfaction-A
  ; B
  set experiential-evaluation-B experiential-importance * experiential-satisfaction-B
  set values-evaluation-B values-importance * values-satisfaction-B
end


;;;;;;;;;;;;;;;;;
;;; Reporters ;;;
;;;;;;;;;;;;;;;;;

to-report random-normal-trunc [avg sd mmin mmax]
  ; creating a trunc normal function to be used for tuncating the normal distribution between mmin and mmax values
  let result random-normal avg sd
  if result < mmin or result > mmax
  [report random-normal-trunc avg sd mmin mmax]
  report result
end


to-report normalized-min-max [norm-variable min-old max-old min-new max-new]
  let norm min-new + (((norm-variable - min-old) * (max-new - min-new)) / (max-old - min-old))
  report norm
end

; dissatisfying-status-CA and satisfying-status-CA should be merged into one reposrting procedure, however it seems that operators cannot be inputs in reporting procedures

to-report dissatisfying-status-CA [evaluations-list-CA]
 let dissatisfying-list-CA filter [i -> i < 0] evaluations-list-CA
 let dissatisfying-stat-CA abs sum dissatisfying-list-CA
 report dissatisfying-stat-CA
end


to-report satisfying-status-CA [evaluations-list-CA]
 let satisfying-list-CA filter [i -> i > 0] evaluations-list-CA
 let satisfying-stat-CA abs sum satisfying-list-CA
 report satisfying-stat-CA
end


to-report dissonance-status [sat dis] ; sat-A is satisfying-A and dis-A is dissatisfying-A
  let dissonant min (list sat dis)
  let consonant max (list sat dis) ; in case of the same values, it does not matter
  let dissonance (2 * dissonant)/(dissonant + consonant)
  report dissonance
end


to-report shading [dissonance-str]
 let shade normalized-min-max (-1 * dissonance-str) -1 0 -5 0
 report shade
end


to-report further-comparison-needed? [comparison-dimension-A comparison-dimension-B theoretical-range]
  let value 0
  ifelse (comparison-dimension-A > comparison-dimension-B - 0.1 * theoretical-range) and (comparison-dimension-A < comparison-dimension-B + 0.1 * theoretical-range) [set value true] [set value false]
  report value
end


to-report same-CA? [ego-val alter-val]
  ;
  ifelse ego-val = alter-val
  [report 1] ; 1 is the same CA
  [report 0] ; 0 is different CA
end


to-report relative-aspiration [aspiration-influencing aspiration-influenced] ; produces values <0 ; 1 > - weighing of the influenced agent's status
  ; for inquiring the influencing agent is the alter, who is influencing the ego
  ; for signlaing the influencing agent is the ego, who is influencing the alter
  let rel-aspiration 0.4 + aspiration-influencing - aspiration-influenced
  if 0.4 + aspiration-influencing - aspiration-influenced > 1 [set rel-aspiration 1]
  if 0.4 + aspiration-influencing - aspiration-influenced < 0 [set rel-aspiration 0]
  report precision rel-aspiration 3
end


to-report sort-list [the-list prio-1 prio-2 prio-3]
  ; the same sorting reporter for inquiring and signaling lists, just used with different priority characteristics
  ; the-list = the nested list you want to sort ; prio-1 = the first prio characteristic; prio-2 = the second prio characteristic; prio-3 - the third prio characteristic
  ; the ego inquires with alters who a) have not been inquired with yet b) choose the same alternative and c) are the most persuasive (sum of aspiration*similarity over experiential and values for both CAs please note that the most persuasive only plays part once ego inquired with all alters in its social network)
  ; the ego signals to alters who a) have not been signaled to yet b) choose a different alternative and c) are the most gullible

  ; first sorts by prio-1 -- if the two prio-1s are equal then it sorts by prio-2, and if those are equal then prio-3

  let sorted sort-by [
    [?a ?b] -> ifelse-value (item prio-1 ?a) != (item prio-1 ?b) [ (item prio-1 ?a) < (item prio-1 ?b) ] [
      ifelse-value (item prio-2 ?a) != (item prio-2 ?b) [ (item prio-2 ?a) > (item prio-2 ?b) ] [ (item prio-3 ?a > item prio-3 ?b) ]
    ]
  ] shuffle the-list

  report sorted
end


to-report need-similarity [need-evaluation-CA-ego need-evaluation-CA-alter need-importance-ego need-importance-alter] ; weighing of alter's similarity of needs, applicable to each group of needs for each CA
  ; can take a max value of 0,4 - if two agents value the same needs to the same extent, the influencing agent affects the influenced agent to a max degree of 40% (new value is 60% influnced agent's and 40% influencing agent).
  ; if two agents don't find the same needs important, the influencing agent does not affect the influenced agent
  ifelse
  (need-evaluation-CA-ego > 0 and need-evaluation-CA-alter > 0) or
  (need-evaluation-CA-ego < 0 and need-evaluation-CA-alter < 0)
  [report 0.4 * (1 - abs(need-importance-ego - need-importance-alter))]
  [report 0]
end


to-report new-need-satisfaction-inquiring [need-satisfaction-CA #item #item2]
  ; the #item refers to the number of item on the list, which designates inquiring persuasion for each need-satisfaction-CA
  ; the #item2 refers to the number of item on the list, which designates need-satisfaction-CA of alter
  ; when humats are persuaded by other humats in their social networks, they change their satisfactions of needs for CAs to the extent that the alter is persuasive (status * similar of needs importances for the CA)
  ; reports a new value of needs satisfaction for a persuaded HUMAT
  ; done for experiential needs and values of both CAs
  let val (1 - item #item inquired-humat) * need-satisfaction-CA + item #item inquired-humat * item #item2 inquired-humat
  report val
end


; to do: whis is to take into account that signaled-humat is the convincing's humat list and here it assumes to be the convinced's humat list - to change
to-report new-need-satisfaction-signaling [need-satisfaction-CA #item]
  ; the #item refers to the number of item on the list, which designates signaling persuasion for each need-satisfaction-CA
  ; when humats are persuaded by other humats in their social networks, they change their satisfactions of needs for CAs to the extent that the alter is persuasive (status * similar of needs importances for the CA)
  ; reports a new value of needs satisfaction for a persuaded HUMAT
  ; done for experiential needs and values of both CAs
  report (1 - item #item signaling-humat) * need-satisfaction-CA + item #item signaling-humat * [need-satisfaction-CA] of myself
end


to-report random-beta [ #alpha #beta ]
  ; reports a score drawn from a beta distrubution with two shape parapeters: alpha and beta
  ; values for a population of 100
  ; #alpha = 4, #beta = 4 - > symmetric with a mean close to 0
  ; #alpha = 8, #beta = 4 -> slightly left-skewed
  ; #alpha = 12, #beta = 4 -> heavily left-skewed
  ; #alpha = 4, #beta = 8 -> slightly right-skewed
  ; #alpha = 4, #beta = 12 -> heavily right-skewed

  let Xa random-gamma #alpha 1
  let Xb random-gamma #beta 1
  let result Xa / (Xa + Xb)
  report result

end

to-report frequency [an-item a-list]
    report length (filter [ i -> i = an-item] a-list)
end
@#$#@#$#@
GRAPHICS-WINDOW
538
10
1001
474
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-45
45
-45
45
1
1
1
ticks
60.0

BUTTON
6
25
72
58
NIL
setup
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
73
25
150
58
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
8
210
235
330
experiential need
NIL
NIL
-1.05
1.05
0.0
25.0
true
true
"" ""
PENS
"importance" 0.05 1 -16777216 true "" "histogram [experiential-importance] of HUMATS"
"satisfaction A" 0.05 0 -13840069 true "" "histogram [experiential-satisfaction-A] of humats"
"satisfaction B" 0.05 0 -5825686 true "" "histogram [experiential-satisfaction-B] of humats"

PLOT
8
333
235
453
social need
NIL
NIL
-1.05
1.05
0.0
25.0
true
true
"" ""
PENS
"importance" 0.05 1 -16777216 true "" "histogram [social-importance] of HUMATS"
"satisfaction A" 0.05 0 -13840069 true "" "histogram [social-satisfaction-A] of HUMATS"
"satisfaction B" 0.05 0 -5825686 true "" "histogram [social-satisfaction-B] of HUMATS"

PLOT
305
210
532
330
values
NIL
NIL
-1.05
1.05
0.0
25.0
true
true
"" ""
PENS
"importance" 0.05 1 -16777216 true "" "histogram [values-importance] of HUMATS"
"satisfaction A" 0.05 0 -13840069 true "" "histogram [values-satisfaction-A] of HUMATS"
"satisfaction B" 0.05 0 -5825686 true "" "histogram [values-satisfaction-B] of HUMATS"

MONITOR
203
115
270
160
% A
precision ((count humats with [chosen = \"A\"] / count humats )* 100) 0
17
1
11

BUTTON
152
25
230
58
go+
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
6
59
178
92
N-HUMATS
N-HUMATS
0
200
178.0
1
1
NIL
HORIZONTAL

MONITOR
271
115
339
160
% B
precision ((count humats with [chosen = \"B\"] / count humats )* 100) 0
17
1
11

PLOT
1008
60
1310
219
HUMATS reducing dissonances
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
"inquiring?" 1.0 0 -8630108 true "" "plot count turtles with [inquiring? = 1]"
"signaling?" 1.0 0 -11221820 true "" "plot count turtles with [signaling? = 1]"

MONITOR
1008
12
1094
57
% dissonant
precision ((count humats with [inquiring? = 1] + count humats with [signaling? = 1]) / count humats * 100) 0
17
1
11

CHOOSER
7
115
199
160
A-experiential-satisfaction
A-experiential-satisfaction
"heavily left-skewed" "slightly left-skewed" "symmetric" "slightly right-skewed" "heavily right-skewed"
2

CHOOSER
342
115
532
160
A-values-satisfaction
A-values-satisfaction
"heavily left-skewed" "slightly left-skewed" "symmetric" "slightly right-skewed" "heavily right-skewed"
2

CHOOSER
7
162
199
207
B-experiential-satisfaction
B-experiential-satisfaction
"heavily left-skewed" "slightly left-skewed" "symmetric" "slightly right-skewed" "heavily right-skewed"
2

CHOOSER
342
162
532
207
B-values-satisfaction
B-values-satisfaction
"heavily left-skewed" "slightly left-skewed" "symmetric" "slightly right-skewed" "heavily right-skewed"
2

PLOT
1009
225
1209
375
Average satisfaction from chosen BA
NIL
NIL
-1.0
1.0
-0.1
0.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [satisfaction] of humats"

MONITOR
1212
226
1311
271
Avg satisfaction
mean [satisfaction] of humats
3
1
11

@#$#@#$#@
## WHAT IS IT?

In some networks, a few "hubs" have lots of connections, while everybody else only has a few.  This model shows one way such networks can arise.

Such networks can be found in a surprisingly large range of real world situations, ranging from the connections between websites to the collaborations between actors.

This model generates these networks by a process of "preferential attachment", in which new network members prefer to make a connection to the more popular existing members.

## HOW IT WORKS

The model starts with two nodes connected by an edge.

At each step, a new node is added.  A new node picks an existing node to connect to randomly, but with some bias.  More specifically, a node's chance of being selected is directly proportional to the number of connections it already has, or its "degree." This is the mechanism which is called "preferential attachment."

## HOW TO USE IT

Pressing the GO ONCE button adds one new node.  To continuously add nodes, press GO.

The LAYOUT? switch controls whether or not the layout procedure is run.  This procedure attempts to move the nodes around to make the structure of the network easier to see.

The PLOT? switch turns off the plots which speeds up the model.

The RESIZE-NODES button will make all of the nodes take on a size representative of their degree distribution.  If you press it again the nodes will return to equal size.

If you want the model to run faster, you can turn off the LAYOUT? and PLOT? switches and/or freeze the view (using the on/off button in the control strip over the view). The LAYOUT? switch has the greatest effect on the speed of the model.

If you have LAYOUT? switched off, and then want the network to have a more appealing layout, press the REDO-LAYOUT button which will run the layout-step procedure until you press the button again. You can press REDO-LAYOUT at any time even if you had LAYOUT? switched on and it will try to make the network easier to see.

## THINGS TO NOTICE

The networks that result from running this model are often called "scale-free" or "power law" networks. These are networks in which the distribution of the number of connections of each node is not a normal distribution --- instead it follows what is a called a power law distribution.  Power law distributions are different from normal distributions in that they do not have a peak at the average, and they are more likely to contain extreme values (see Albert & Barabási 2002 for a further description of the frequency and significance of scale-free networks).  Barabási and Albert originally described this mechanism for creating networks, but there are other mechanisms of creating scale-free networks and so the networks created by the mechanism implemented in this model are referred to as Barabási scale-free networks.

You can see the degree distribution of the network in this model by looking at the plots. The top plot is a histogram of the degree of each node.  The bottom plot shows the same data, but both axes are on a logarithmic scale.  When degree distribution follows a power law, it appears as a straight line on the log-log plot.  One simple way to think about power laws is that if there is one node with a degree distribution of 1000, then there will be ten nodes with a degree distribution of 100, and 100 nodes with a degree distribution of 10.

## THINGS TO TRY

Let the model run a little while.  How many nodes are "hubs", that is, have many connections?  How many have only a few?  Does some low degree node ever become a hub?  How often?

Turn off the LAYOUT? switch and freeze the view to speed up the model, then allow a large network to form.  What is the shape of the histogram in the top plot?  What do you see in log-log plot? Notice that the log-log plot is only a straight line for a limited range of values.  Why is this?  Does the degree to which the log-log plot resembles a straight line grow as you add more nodes to the network?

## EXTENDING THE MODEL

Assign an additional attribute to each node.  Make the probability of attachment depend on this new attribute as well as on degree.  (A bias slider could control how much the attribute influences the decision.)

Can the layout algorithm be improved?  Perhaps nodes from different hubs could repel each other more strongly than nodes from the same hub, in order to encourage the hubs to be physically separate in the layout.

## NETWORK CONCEPTS

There are many ways to graphically display networks.  This model uses a common "spring" method where the movement of a node at each time step is the net result of "spring" forces that pulls connected nodes together and repulsion forces that push all the nodes away from each other.  This code is in the `layout-step` procedure. You can force this code to execute any time by pressing the REDO LAYOUT button, and pressing it again when you are happy with the layout.

## NETLOGO FEATURES

Nodes are turtle agents and edges are link agents. The model uses the ONE-OF primitive to chose a random link and the BOTH-ENDS primitive to select the two nodes attached to that link.

The `layout-spring` primitive places the nodes, as if the edges are springs and the nodes are repelling each other.

Though it is not used in this model, there exists a network extension for NetLogo that comes bundled with NetLogo, that has many more network primitives.

## RELATED MODELS

See other models in the Networks section of the Models Library, such as Giant Component.

See also Network Example, in the Code Examples section.

## CREDITS AND REFERENCES

This model is based on:
Albert-László Barabási. Linked: The New Science of Networks, Perseus Publishing, Cambridge, Massachusetts, pages 79-92.

For a more technical treatment, see:
Albert-László Barabási & Reka Albert. Emergence of Scaling in Random Networks, Science, Vol 286, Issue 5439, 15 October 1999, pages 509-512.

Barabási's webpage has additional information at: http://www.barabasi.com/

The layout algorithm is based on the Fruchterman-Reingold layout algorithm.  More information about this algorithm can be obtained at: https://cs.brown.edu/~rt/gdhandbook/chapters/force-directed.pdf.

For a model similar to the one described in the first suggested extension, please consult:
W. Brian Arthur, "Urban Systems and Historical Path-Dependence", Chapt. 4 in Urban systems and Infrastructure, J. Ausubel and R. Herman (eds.), National Academy of Sciences, Washington, D.C., 1988.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (2005).  NetLogo Preferential Attachment model.  http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2005 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2005 -->
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
set layout? false
set plot? false
setup repeat 300 [ go ]
repeat 100 [ layout ]
@#$#@#$#@
@#$#@#$#@
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
