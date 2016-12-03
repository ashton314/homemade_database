;; B+ Tree Library
;; Author: Ashton Wiersdorf
;; Started: Sat  3 Dec 01:27:05 UTC 2016

(require 'macro)

(define *sort-function* string<?)

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
	(keys '())
	(vals '()))

    (define (insert key value)
      (if (< (length keys) max-degree)
	  (call-with-values (lambda () bisect keys key)
	    (lambda (all left right)
	      (set! keys all)
	      'not-finished-here
	      ))

	  (error "not implemented")))

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

(define (bisect sort-function lst pivot)
  ;; splits lst; returns `(,@lst ,pivot ,@lst)
  (let ((left  (grep (lambda (n) (sort-function n pivot)) lst))         ; OPTIMIZE: I actually don't need to filter the whole list;
	(right (grep (lambda (n) (not (sort-function n pivot))) lst)))  ; I just need to locate the right point and splice in the lst
    (values
     (append left
	     (list pivot)
	     right)
     left
     right)))


(define (reduce func lst)
  (define (loop acc loop-lst)
    (if (null? loop-lst)
	acc
	(loop (func acc (car loop-lst)) (cdr loop-lst))))
  (loop (car lst) (cdr lst)))

(define (grep filter lst)
  ;; filters a list. Returns '() if no elements satisfying filter are found
  (define (loop acc loop-lst)
    (cond 
     ((null? loop-lst) (reverse acc))
     ((filter (car loop-lst))
      (loop (cons (car loop-lst) acc)
	    (cdr loop-lst)))
     (else (loop acc (cdr loop-lst)))))

  (loop '() lst))
