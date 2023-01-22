(setq archivo (open (getstring T "Indique la ruta completa del archivo (se recomienda el formato .txt)") "w"))
(defun get-attribute (obj tag / value) (foreach a (vlax-invoke obj 'getattributes) (if (= (vlax-get a 'TagString) tag) (setq value (vlax-get a 'textString)))) value)

(defun get-first-number (string / count return)
	(progn
		(setq count 0)
		(setq return nil)
		(while count
			(if (= count (strlen string))
				(setq count nil)
				(progn
					(if (and (> (vl-string-elt string count) 48) (< (vl-string-elt string count) 58))
						(progn
							(setq return (+ count 1))
							(setq count nil)
						)
						(setq count (+ count 1))
					)
				)
			)
		)
	)
return)

(defun findBlockReference (entidad / return)
	(progn
		(setq return nil)
		(foreach a entidad
			(if (and (= (nth 0 a) 100) (= (cdr a) "AcDbBlockReference"))
			(setq return T))
		)
	)
return)

(setq entidades (ssget))
(setq entidadesVLA ())
(setq count 0)
(setq ROOMS ())
(while count
	(setq entidad (ssname entidades count))
	(if
		(= entidad nil) (setq count nil)
		(progn
			;(if (and (= (nth 0 (nth 11 (entget entidad))) 100) (= (cdr (nth 11 (entget entidad))) "AcDbBlockReference") )
			(if (findBlockReference (entget entidad))
				(setq entidadesVLA (cons (vlax-ename->vla-object entidad) entidadesVLA))
			)
			(setq count (+ count 1))
		)
	)
)
(foreach a entidadesVLA
	(if (and (/= (get-attribute a "ROOM_NUMBER") nil) (/= (get-attribute a "ROOM_NUMBER") ""))
		(progn
			(if (= (get-attribute a "ROOM_NAME") "AR") (setq ROOM_NUMBER (strcat (get-attribute a "ROOM_NAME") " " (get-attribute a "ROOM_NUMBER"))) (setq ROOM_NUMBER (get-attribute a "ROOM_NUMBER")))
			(setq ROOMS (cons (cons ROOM_NUMBER (get-attribute a "GrossAreaText")) ROOMS))
		)
		(if (and (/= (get-attribute a "ROOM_NAME") nil) (/= (get-attribute a "ROOM_NAME") "") (/= (get-attribute a "GrossAreaText") nil) (/= (get-attribute a "GrossAreaText") "") (or (= (substr (get-attribute a "GrossAreaText") 1 1) "A") (= (substr (get-attribute a "GrossAreaText") 1 1) "a")))
			(setq ROOMS (cons (cons (get-attribute a "ROOM_NAME") (get-attribute a "GrossAreaText")) ROOMS))
		)
	)
)
(foreach a ROOMS
	(if (/= (cdr a) nil)
	(write-line (strcat (nth 0 a) "\t" (vl-string-subst "," "." (substr (cdr a) (get-first-number (cdr a))))) archivo)
	)
)
(close archivo)
(prompt "Aplicación finalizada correctamente")