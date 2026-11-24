ALTER SESSION SET nls_date_format = 'DD/MM/YYYY';

--- CASO 1 ---

SELECT
    to_char(c.numrun, '99G999G999')
    || '-'
    || c.dvrun                                 AS "RUT Cliente",
    initcap(c.pnombre
            || ' '
            || c.appaterno)                            AS "Nombre Cliente",
    upper(po.nombre_prof_ofic)                 AS "Profesión Cliente",
    to_char(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
    c.direccion                                AS "Dirección Cliente"
FROM
         cliente c
    JOIN profesion_oficio po ON c.cod_prof_ofic = po.cod_prof_ofic
    JOIN tipo_cliente     tc ON c.cod_tipo_cliente = tc.cod_tipo_cliente
WHERE
        lower(tc.nombre_tipo_cliente) = 'trabajadores dependientes'
    AND upper(po.nombre_prof_ofic) IN ( 'CONTADOR', 'VENDEDOR' )
    AND EXTRACT(YEAR FROM c.fecha_inscripcion) > (
        SELECT
            round(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
        FROM
            cliente
    )
ORDER BY
    c.numrun ASC;
    
--- CASO 2 ---

CREATE TABLE clientes_cupos_compra
    AS
        SELECT
            concat(c.numrun,
                   concat('-',
                          upper(c.dvrun)))                                     AS "RUT_CLIENTE",
            EXTRACT(YEAR FROM sysdate) - EXTRACT(YEAR FROM c.fecha_nacimiento) AS "EDAD",
            to_char(tc.cupo_disp_compra, '$999G999G999')                       AS "CUPO_DISPONIBLE_COMPRA",
            upper(tcl.nombre_tipo_cliente)                                     AS "TIPO_CLIENTE"
        FROM
                 cliente c
            JOIN tarjeta_cliente tc ON c.numrun = tc.numrun
            JOIN tipo_cliente    tcl ON c.cod_tipo_cliente = tcl.cod_tipo_cliente
        WHERE
            tc.cupo_disp_compra >= (
                SELECT
                    MAX(cupo_disp_compra)
                FROM
                    tarjeta_cliente
                WHERE
                    EXTRACT(YEAR FROM fecha_solic_tarjeta) = EXTRACT(YEAR FROM sysdate) - 1
            )
        ORDER BY
            "EDAD" ASC;

SELECT
    *
FROM
    clientes_cupos_compra;