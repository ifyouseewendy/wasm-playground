(module
  (memory $mem 1)

  (global $BLACK i32 (i32.const 1))
  (global $WHITE i32 (i32.const 2))
  (global $CROWN i32 (i32.const 4))
  (global $currentTurn (mut i32) (i32.const 0))

  ;; -- Offset calculation
  ;; Calculate index for a two-dimension board
  (func $indexForPosition (param $x i32) (param $y i32) (result i32)
    (i32.add
      (i32.mul
        (i32.const 8)
        (get_local $y)
      )
      (get_local $x)
    )
  )
  ;; Calculate byte offset for a two-dimension board. Offset = ( x + y * 8) * 4
  (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
    (i32.mul
      (i32.const 4)
      (call $indexForPosition (get_local $x) (get_local $y))
    )
  )

  ;; -- Board piece state prediction
  ;; Determine if a piece is black
  (func $isBlack (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $BLACK))
      (get_global $BLACK)
    )
  )
  ;; Determine if a piece is white
  (func $isWhite (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $WHITE))
      (get_global $WHITE)
    )
  )
  ;; Determine if a piece is crowned
  (func $isCrowned (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $CROWN))
      (get_global $CROWN)
    )
  )
  ;; Add a crown to a given piece
  (func $withCrown (param $piece i32) (result i32)
    (i32.or
      (get_local $piece)
      (get_global $CROWN)
    )
  )
  ;; Remove a crown from a given piece
  (func $withoutCrown (param $piece i32) (result i32)
    (i32.and
      (get_local $piece)
      (i32.const 3)
    )
  )

  ;; -- Board piece getter and setter
  ;; Set a piece on the board
  (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
    (i32.store
      (call $offsetForPosition
        (get_local $x)
        (get_local $y)
      )
      (get_local $piece)
    )
  )
  ;; Detect if values are within valid range (inclusive high and low)
  (func $inRange (param $low i32) (param $high i32) (param $value i32) (result i32)
    (i32.and
      (i32.ge_s (get_local $value) (get_local $low))
      (i32.le_s (get_local $value) (get_local $high))
    )
  )
  ;; Get a piece from the board. Out of range causes a trap
  (func $getPiece (param $x i32) (param $y i32) (result i32)
    (if (result i32)
      (block (result i32)
        (i32.and
          (call $inRange (i32.const 0) (i32.const 7) (get_local $x))
          (call $inRange (i32.const 0) (i32.const 7) (get_local $y))
        )
      )
      (then
        (i32.load
          (call $offsetForPosition (get_local $x) (get_local $y))
        )
      )
      (else
        (unreachable)
      )
    )
  )

  ;; -- Turn owner
  ;; Get the current turn owner (white or black)
  (func $getTurnOwner (result i32)
    (get_global $currentTurn)
  )
  ;; Set the turn owner
  (func $setTurnOwner (param $piece i32)
    (set_global $currentTurn (get_local $piece))
  )
  ;; At the end of a turn, switch turn owner to the other player
  (func $toggleTurnOwner
    (if (i32.eq (get_global $currentTurn) (i32.const 1))
      (then (call $setTurnOwner (i32.const 2)))
      (else (call $setTurnOwner (i32.const 1)))
    )
  )
  ;; Determine if it's a player's turn
  (func $isPlayerTurn (param $player i32) (result i32)
    (i32.gt_s
      (i32.and (get_local $player) (call $getTurnOwner))
      (i32.const 0)
    )
  )

  (export "offsetForPosition" (func $offsetForPosition))

  (export "isCrowned" (func $isCrowned))
  (export "isWhite" (func $isWhite))
  (export "isBlack" (func $isBlack))
  (export "withCrown" (func $withCrown))
  (export "withoutCrown" (func $withoutCrown))

  (export "getPiece" (func $getPiece))
  (export "setPiece" (func $setPiece))

  (export "getTurnOwner" (func $getTurnOwner))
  (export "toggleTurnOwner" (func $toggleTurnOwner))
  (export "isPlayerTurn" (func $isPlayerTurn))
)
