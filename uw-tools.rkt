;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Name: Yue Zhu
;; Student ID: 20534753
;; File: uw-tools.rkt 
;; CS 136 Fall 2014 - Assignment 1, Problem 5
;; Description: A group of convenience functions
;;  for accessing the UWaterloo API. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#lang racket

;; A module of some useful tools by using uw API.

(require "uw-api.rkt")

(provide course-desc
         needs-consent?
         full-courses
         course-sections
         section-info
         next-holiday
         room-status)

;; PARAMETERS:

;;    *subject is a non-empty string that is a UW 
;;       subject (e.g., "CS" or "MATH").
;;    *catalog is an integer corresponding the course 
;;       number (e.g., the catalog number for this 
;;       course is 136).
;;    *catalog-list is a list of catalog numbers.
;;    *term is a 4-digit integer that uses UW's term 
;;       numbering system (see /terms/list in the 
;;       api). If you're curious, the first digit is 
;;       always 1, the next two digits are the year, 
;;       and the last digit is the starting month of 
;;       the semester (W = 1, S = 5, F = 9), so S14 is 
;;       1145.
;;    *section is a 7-character string corresponding 
;;       to a course section (e.g., "LEC 001" or "TST 
;;       201").
;;    *date is a a 10-character string in YYYY-MM-DD 
;;       format (e.g., "2014-01-10")
;;    *building is a non-empty string corresponding to 
;;       a campus building (e.g., "MC")
;;    *room is an integer corresponding to a room 
;;       number (e.g., 4059)
;;    *day is a 1 or 2 character string that is one 
;;       of: "M", "T", "W", "Th", "F"
;;    *time is a 5 character string in 24-hour format 
;;       (e.g., "13:30")

;; FUNCTIONS:

;; course-desc : String Int -> String
;;    PRE: non-empty String
;;    POST: produce a String
;; Purpose:    (course-desc subject catalog)
;;          Consume a String, subject, and a Int, 
;;          catalog. Produce a string with the 
;;          calendar "description" of the course.
;;          It shows the course description of the
;;          course.

;; needs-consent? : String Int -> Boolean
;;    PRE: non-empty String.
;;    POST: Produce #t if enrollment in 
;;          the course needs both the consent of 
;;          the instructor and the consent of the 
;;          department, and #f otherwise.
;; Purpose:    (needs-consent? subject catalog)
;;          Consume a String, subject, and a Int, 
;;          catalog. Produce #t or #f under certain
;;          condition(see POST). It determines
;;          whether the couse needs the consent of 
;;          both instructor and department.

;; full-courses : String (listof Int) -> (listof Int)
;;    PRE: non-empty String
;;    POST: a list of Int
;; Purpose:    (full-courses subject catalog-list)
;;          Consume a String, subject, and a (listof 
;;          Int), catalog-list. Produce a list of 
;;          catalog numbers that are in catalog-list 
;;          and are worth at least 0.5 course units. 
;;          The courses are listed in the same order 
;;          as in catalog-list. 

;; course-sections : Int String Int -> (listof String)
;;    PRE: non-empty String
;;    POST: a list of String
;; Purpose:    (course-sections term subject catalog)
;;          Consume two Ints, term catalog, and a 
;;          String, subject. Produces a list of 
;;          strings that correspond to the section 
;;          names for the course. 

;; section-info : Int String Int String -> String
;;    PRE: non-empty String(subject)
;;         7-character String(section)
;;         4-digit Int(term)
;;    POST: a String in certain format(see below)
;; Purpose:(section-info term subject catalog section)
;;          Consume two Ints, term catalog, and two 
;;          Strings, subject section. Produce a single
;;          string with information about a particular 
;;          section.
;;   The format of the string:
;;     "[SUBJECT] [CATALOG][SECTION] [start_time]-
;;      [end_time] [weekdays] [building] [room] 
;;      [instructor]"

;; next-holiday : String -> String
;;    PRE: 10-character String in YYYY-MM-DD format 
;;    POST: produce a String in certain format
;;          (see below)
;;          [NEXT-HOLIDAY-DATE]is in YYYY-MM-DD format
;; Purpose:    (next-holiday date)
;;          Consume a String, date. Produce a string 
;;          with the next holiday on or after the date 
;;          provided. 
;;   The format of the string: 
;;     "[NEXT-HOLIDAY-DATE] [NEXT-HOLIDAY-NAME]"

;; room-status : String Int String String -> String
;;    PRE: non-empty String(building)
;;         1 or 2 character String(day) that is
;;         one of: "M", "T", "W", "Th", "F"
;;         5 character String(time) in 24-hour format 
;;    POST: produce a String in certain format
;;          (see below)
;; Purpose:    (room-status building room day time)
;;          Consume three Strings, building day time, 
;;          and a Int, room. produces a string that 
;;          displays the course in the room at that 
;;          day and time, or "FREE" if the room is not 
;;          in use. 
;;   The format of the string: 
;;     "[SUBJECT] [CATALOG] [DESCRIPTION]"

;; EXAMPLES:

;; (course-desc "CS" 136) 
;; (needs-consent? "MATH" 692)
;; (needs-consent? "CS" 136)
;; (full-courses "MATH" '(97 641 118 51 103))
;; (section-info 1145 "CS" 136 "LEC 001")
;; (next-holiday "2014-01-10") 
;; (room-status "MC" 2017 "T" "12:50")
;; (room-status "MC" 2054 "Th" "11:21")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; an APIResult is one of:
;; * (list "key" value) [where value is (union Num String)]
;; * (list "key" APIResult)               
;; * (listof APIResult)

;; input-api1 : String Int -> (listof APIResult)
;;    PRE: non-empty String
;;    POST: produce a list of APIResult.
;; Purpose: Helper function (input-api1 subject catalog)
;;          Consume a String, subject, and a Int, 
;;          catalog.
;;          Produce a APIResult of (uw-api 
;;          "/courses/[SUBJECT]/[CATALOG]")
;;          It help us enter information conveniently.
(define (input-api1 subject catalog)
  (uw-api (string-append "/courses/" subject "/" 
                         (number->string catalog))))

;; rec : (listof list) Any -> Any
;;    PRE: true
;;    POST: produce Any
;; Purpose: Helper function (rec l key)
;;          Consume a (listof list), l, and Any, key.
;;          Produce a value(second argument of 
;;          element-list) when key is the first 
;;          argument of the element-list. 
(define (rec l key)
  (cond
    [(empty? l) (printf "")]
    [(equal? (first (first l)) key)
     (second (first l))]
    [else (rec (rest l) key)]))

;; See interface above.
(define (course-desc subject catalog)
  (rec (input-api1 subject catalog) "description"))

;; See interface above.
(define (needs-consent? subject catalog)
  (cond
    [(and (equal? 
           (rec (input-api1 subject catalog) 
             "needs_department_consent") #t)
          (equal? 
           (rec (input-api1 subject catalog) 
             "needs_instructor_consent") #t)) #t]
    [else #f]))

;; See interface above.
(define (full-courses subject catalog-list)
  (cond
    [(equal? catalog-list empty) empty]
    [(>= (rec (input-api1 subject 
                          (first catalog-list)) 
              "units") 0.5) 
     (cons (first catalog-list) 
           (full-courses subject 
                         (rest catalog-list)))]
    [else (full-courses subject 
                        (rest catalog-list))]))

;; input-api2 : Int String Int -> (listof APIResult)
;;    PRE: 4-digit Int(term)
;;         non-empty String(subject)
;;    POST: produce a list of APIResult
;; Purpose: Helper (input-api2 term subject catalog)
;;          Consume a String, subject, and two Int, 
;;          term catalog.
;;          Produce a APIResult of (uw-api 
;;       "/terms/[TERM]/[SUBJECT]/[CATALOG]/schedule")
;;          It help us enter information conveniently.
(define (input-api2 term subject catalog)
  (uw-api (string-append "/terms/" 
                         (number->string term) "/" 
                         subject "/" 
                         (number->string catalog) 
                         "/schedule")))

;; rec2 : (listof list) Any -> (listof Any)
;;    PRE: the type of element list must be (listof 
;;         list)
;;    POST: produce a list of Any
;; Purpose: Helper function (rec2 l key)
;;          Consume a (listof list), l, and Any, key.
;;          Produce a list of the values(second 
;;          argument of all posible element-lists) 
;;          when key is the first argument of the 
;;          element-list. It help us find information
(define (rec2 l key)
  (cond
    [(empty? l) empty]
    [else (cons (rec (first l) key) 
                (rec2 (rest l) key))]))

;; See interface above.
(define (course-sections term subject catalog)
  (rec2 (input-api2 term subject catalog) "section"))

;; find-section : (listof APIResult) String -> (listof 
;;                APIResult)
;;    PRE: non-empty String
;;    POST: produce a list of APIResult
;; Purpose: Helper function (find-section l section)
;;          Consume a (listof APIResult), l, and a 
;;          String, section.
;;          Produce a value(listof APIResult) whose 
;;          key is section.
(define (find-section l section)
  (cond
    [(empty? l) empty]
    [(equal? (rec (first l) "section") section) 
     (rec (first l) "classes")]
    [else (find-section (rest l) section)]))

;; find-info : (listof APIResult) String -> String
;;    PRE: non-empty String
;;    POST: produce a String
;; Purpose: Helper function (find-info l info)
;;          Consume a (listof APIResult), l, and a 
;;          String, info.
;;          Produce a value(String) whose key is info.
(define (find-info l info)
  (cond
    [(empty? l) empty]
    [(equal? "date-start" info) 
     (second (first (rec (first l) "date")))]
    [(equal? "date-end" info) 
     (second (second (rec (first l) "date")))]
    [(equal? "date-week" info) 
     (second (third (rec (first l) "date")))]
    [(equal? "location-building" info) 
     (second (first (rec (first l) "location")))]
    [(equal? "location-room" info) 
     (second (second (rec (first l) "location"))) ]
    [else (first (rec (first l) "instructors"))]))

;; See interface above.
(define (section-info term subject catalog section)
  (string-append 
   subject " " (number->string catalog) " " section " "
   (find-info (find-section (input-api2 term subject catalog) section) "date-start") "-"
   (find-info (find-section (input-api2 term subject catalog) section) "date-end") " "
   (find-info (find-section (input-api2 term subject catalog) section) "date-week") " "
   (find-info (find-section (input-api2 term subject catalog) section) "location-building") " "
   (find-info (find-section (input-api2 term subject catalog) section) "location-room") " "
   (find-info (find-section (input-api2 term subject catalog) section) "instructors")))

;; myremove : Any (listof Any) -> (listof Any)
;;    PRE: true
;;    POST: produce a list of Any
;; Purpose: Consume Any, sth, and a (listof Any), lst.
;;          Produce a (listof Any) without the first 
;;          occurence of sth.
(define (myremove sth lst)
  (cond
    [(empty? lst) empty]
    [(equal? (first lst) sth) (rest lst)]
    [else (cons (first lst) 
                (myremove sth (rest lst)))]))

;; transfer-s-to-n : String -> Num
;;    PRE: String includes numbers except two "-"s.
;;    POST: produce a Num
;; Purpose: Helper function (transfer-s-to-n s)
;;          Consume a String, s(date).
;;          Produce a Num without the two occurences 
;;          of "-".
(define (transfer-s-to-n s)
  (string->number (list->string (myremove #\- (myremove #\- (string->list s))))))

;; find-next-date:(listof APIResult) String -> String
;;    PRE: 10-character String(date) in 
;;         YYYY-MM-DD format
;;    POST: produce a String in certain format
;;          (see below)
;;          [NEXT-HOLIDAY-DATE]is in YYYY-MM-DD format
;; Purpose: Helper function (find-next-date l ndate)
;;          Consume a (listof APIResult), l, and a 
;;          String, date. 
;;          Produce a string with the next holiday on 
;;          or after the date provided. 
(define (find-next-date l ndate)
  (cond
    [(empty? l) (printf "")]
    [(> (transfer-s-to-n (second (first (first l)))) 
        (transfer-s-to-n ndate)) 
     (string-append 
      (second (first (first l))) " " 
      (second (second (first l))))]
    [else (find-next-date (rest l) ndate)]))

;; See interface above.
(define (next-holiday date)
  (find-next-date (uw-api "/events/holidays") date))

;; input-api3 : String Int -> (listof APIResult)
;;    PRE: non-empty String
;;    POST: produce a list of APIResult
;; Purpose: Helper (input-api3 building room)
;;          Consume a String, building, and a Int, 
;;          room.
;;          Produce a APIResult of (uw-api 
;;          (/buildings/[BUILDING]/[ROOM]/courses)
;;          It help us enter information conveniently.
(define (input-api3 building room)
  (uw-api (string-append 
           "/buildings/" building "/" 
           (number->string room) "/courses")))

;; weekdays? : String String -> Boolean
;;    PRE: String(day)should be one of 
;;         "M" "T" "W" "Th" "F".
;;         String(week) should be the combination of 
;;         "M" "T" "W" "Th" "F".
;;    POST: Produce #t if week(second string) contains 
;;          the day(first string) in a week. 
;;          Otherwise #f
;; Purpose: Helper function (weekdays? day week)
;;          Consume two String, day week.
;;          Produce #t or #f under certain condition
;;          (see POST) it help us judge whether week
;;          includes the day.
(define (weekdays? day week)
  (cond
    [(member #\h (string->list day)) 
     (if (member #\h (string->list week)) #t #f)]
    [else 
     (if (member #\h (string->list week))
         (if (member (first (string->list day)) 
                     (myremove #\T (string->list week))) #t #f)
         (if (member (first (string->list day)) 
                     (string->list week)) #t #f))]))

;; change-time : String -> Num
;;    PRE: String includes numbers except for one ":".
;;    POST: produce a Num without the two occurences 
;;          of "-".
;; Purpose: Helper function (change-time time)
;;          Consume a String, s(date).
;;          Produce a Num without the two occurences 
;;          of "-". It changes time in to number.
(define (change-time time)
  (string->number 
   (list->string (myremove #\: (string->list time)))))

;; time? : String String String -> Boolean
;;    PRE: each of three Strings can be used in 
;;         function change-time.
;;    POST: Produce #t if time is greater than or 
;;          equal to start-t and is less than or equal 
;;          to end-t after transferred to numbers. 
;;          Otherwise #f
;; Purpose: Helper function(time? time start-t end-t)
;;          Consume three Strinng, time start-t end-t.
;;          Produce #t or #f under certain condition
;;          (see POST) It judges whether time point is
;;          during a course.
(define (time? time start-t end-t)
  (cond
    [(and (<= (change-time time) (change-time end-t))
          (>= (change-time time) 
              (change-time start-t))) #t]
    [else #f]))

;; help-room-status : String String (listof APIResult) -> String
;;    PRE: 1 or 2 character String(day) that is one 
;;         of: "M", "T", "W", "Th", "F"
;;         5 character String(time) in 24-hour format
;;    POST: produce a String
;; Purpose: Helper (help-room-status day time l)
;;          Consume two Strings, day time, and a 
;;          (listof APIResult), l.
;;          Produce a string that displays the course 
;;          in the room at that day and time, or 
;;          "FREE" if the room is not in use. 
(define (help-room-status day time l)
  (cond
    [(empty? l) "FREE"]
    [(and (equal? 
           (weekdays? day (rec (first l) "weekdays"))
           #t)
          (equal? 
           (time? time (rec (first l) "start_time") 
                  (rec (first l) "end_time")) #t))
     (string-append (rec (first l) "subject") " " 
                    (rec (first l) "catalog_number") 
                    " " (rec (first l) "title"))]
    [else (help-room-status day time (rest l))]))

;; See interface above.
(define (room-status building room day time)
  (help-room-status day time 
                    (input-api3 building room)))