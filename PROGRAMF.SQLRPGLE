     HDEBUG(*YES)
     HOPTION(*NODEBUGIO)
     FEMBED_DSP2CF   E             WORKSTN
     F                                     SFILE(EMBED_SFL:RRN)
     F                                     INFDS(infds)
    *
     Dinfds            DS
     DRECNO                  378    379I 0
     D RRN             S              3S 0 inz(0)
     DF1               S             10A
     DF2               S             10A
    *C     *ENTRY        PLIST
     C                   PARM                    F1
     C                   PARM                    F2

      /FREE

        // Inicio de programa princioal:
        DOW *IN03 = *OFF;
          LEAVE;
          EXSR DSPSFL;
        ENDDO;
        *INLR = *ON;

        // Sub rutinas:

          //Limpiar SUBFILE:
            BEGSR CLRSFL;
              RRN = 0;
              *IN40 = *ON;
              WRITE EMBED_CTL;
              *IN40 = *OFF;
            ENDSR;

          //Inicio de pantalla:
            BEGSR *INZSR;
              *IN40 = *OFF;
              *IN41 = *OFF;
              *IN42 = *OFF;
              *IN45 = *OFF;
              RRN = 0;
              FIRSTRRN = 1;
              EXSR CLRSFL;
              EXSR FILSFL;
              EXSR DSPSFL;
            ENDSR;

          //Rellenar Subfile:
            BEGSR FILSFL;
               RRN = 1;
               EXEC SQL
                 DECLARE C1 SCROLL CURSOR FOR
                 SELECT
                   c.TSTFCOD,
                   c.TSTFCED,
                   c.TSTFNOM,
                   c.TSTFAPE,
                   count(m.TSTF02FID) as total_registros,
                   sum(m.TSTF02VAL) as valor_total,
                   m.TSTF02FECH
                 FROM CAPACITA21/TSTF01P C
                 INNER JOIN CAPACITA21/TSTF02P m
                 ON c.TSTFCOD = m.TSTF02COD
                 WHERE m.TSTF02FECH BETWEEN :F1 AND :F2
                 GROUP BY
                   c.TSTFCOD,
                   c.TSTFCED,
                   c.TSTFNOM,
                   c.TSTFAPE,
                   m.TSTF02FECH
                 ORDER BY TSTF02FECH;

               EXEC SQL
                 OPEN C1;

               EXEC SQL
                FETCH FIRST FROM C1 INTO :COD,:CED,:NOM,:APE,:REG,:VAL,:FEC;

               DOW SQLCOD = 0;
                WRITE EMBED_SFL;

                EXEC SQL
                 FETCH NEXT FROM C1 INTO :COD,:CED,:NOM,:APE,:REG,:VAL,:FEC;

                 RRN=RRN+1;
               ENDDO;

               IF SQLCOD = 100;
                 *IN45 = *ON;

                 EXEC SQL
                   CLOSE C1;

               ENDIF;
            ENDSR;

            //Mostrar subfile:
            BEGSR DSPSFL;
              *IN41 = *ON;
              *IN42 = *ON;
              IF RRN<=0;
               *IN42 = *OFF;
              ENDIF;
              WRITE FOOTER;
              EXFMT EMBED_CTL;
              FIRSTRRN =RECNO;
              *IN41 = *OFF;
              *IN42 = *OFF;
            ENDSR;
      /end-free                                                                             
