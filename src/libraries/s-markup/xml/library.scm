;;  This file is part of the 'AutoScheme' project.
;;  Copyright 2021 Steven Wiley <s.wiley@katchitek.com> 
;;  SPDX-License-Identifier: BSD-2-Clause

(define-library (s-markup xml)
  (import 
	  )

  (export display-xml write-xml)

  (begin 
    (define keyword? 
      (lambda (obj)
	(and (symbol? obj)
	     (equal? (car (reverse (string->list (symbol->string obj)))) #\: ))))
    


    (define keyword->string
      (lambda (obj)
	(list->string (reverse (cdr (reverse (string->list (symbol->string obj))))))))


    (define debug-xml-linebreak "")




		   

    (define replace-special-chars
      (lambda (s)

	(string-map (lambda (c)
		      (cond ((equal? c #\&) "&amp;")
			    ((equal? c #\") "&quot;")
			    ((equal? c #\') "&apos;")
			    ((equal? c #\<) "&lt;")
			    ((equal? c #\>) "&gt;")
			    ((equal? c #\xA9) "&copy;")
			    ((equal? c #\lambda) "&lambda;")
			    (else (string c))))
		    s)))

    	;; (string-substitute* s '(("&" . "&amp;") 
	;; 			("\"" . "&quot;")("'" . "&apos;")("<" . "&lt;")(">" . "&gt;")
	;; 			("©" . "&copy;") ("lambda" . "&lambda;")))))


    (define remainder->xml
      (lambda (type remainder)
	(cond ((null? remainder) (cond ((string-prefix? "?" (symbol->string type)) "?>")
				       (else (string-append " />"))))
	      
	      ((keyword? (car remainder)) (string-append " " (keyword->string (car remainder)) "=\"" 
							 (replace-special-chars (cadr remainder)) "\"" 
							 (remainder->xml type (cddr remainder))))

	      (else (string-append ">" debug-xml-linebreak (apply string-append (map object->xml remainder)) 
				   "</" (symbol->string type) ">")))))


    (define object->xml 
      (lambda (obj)
	(string-append (cond ((char? obj) (cond ((equal? obj #\space) "&nbsp;")
						(else (error "unknown character"))))
			     
			     ((string? obj) (replace-special-chars obj))

			     (else (let ((type (car obj))
					 (remainder (cdr obj)))

				     (cond ((equal? type '!DOCTYPE) (string-append "<!DOCTYPE" (with-output-to-string (lambda () (map (lambda (o) (display " ") (write o)) (cdr obj)))) ">"))
					   ((string-prefix? "!--" (symbol->string type)) (string-append "<" (symbol->string type) (car remainder) "-->"))
					   (else (string-append "<" (symbol->string type) (remainder->xml type remainder)))))))
		       debug-xml-linebreak)))


    (define display-xml
      (lambda (l)
	(for-each (lambda (obj) (display (object->xml obj))) l)))
    

    (define write-xml
      (lambda (l)
	(for-each (lambda (obj) (write (object->xml obj))) l)))
    
    ))