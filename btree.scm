;; B+ Tree Library
;; Author: Ashton Wiersdorf
;; Started: Sat  3 Dec 01:27:05 UTC 2016

(require 'macro)

(define-syntax def-or
  (syntax-rules ()
    ((def-or variable default-datum)
     (if (defined? variable) variable default-datum))))

(define (new-node max-degree)
  ;; This function should return a new node object.
  ;; A node looks like this:
  ;;
  ;;  [	    key1    key2    key3    key4     ]
  ;;  [ ref0    ref1    ref2    ref3    ref4 ]

  (let ((leaf? #t)
	(parent #f)
	(keys '())			; OPTIMIZE: make these arrays
	(vals '()))

    (define (insert key value)
      

    (define (node message . args)
      ;; This function will be returned. It is a closure. "Messages"
      ;; passed to this function will invoke certain actions. This is
      ;; like an object.

      ;; Examples:
      ;; (insert <key> <value>)
      ;; (search <key>)
      ;; (leaf?)

      (case message
	((insert) (insert (car args) (cadr args)))
	((search) (search (car args)))
	((parent) parent)
	((leaf?) leaf?)
	(else (error "aah!"))))


    node))
