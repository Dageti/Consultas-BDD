--- CASO 1 FACTURAS ---
SELECT
    to_char(fecha, 'DD "de" Month YYYY') AS "Fecha Emision",
    numfactura                           AS "N° Factura",
    lpad(rutcliente, 10, 0)              AS "RUT Cliente",
    to_char(neto, '$999G999G999')        AS "Monto Neto",
    to_char(iva, '$999G999G999')         AS "Monto IVA",
    to_char(total, '$999G999G999')       AS "Total Factura",
    CASE
        WHEN total BETWEEN 0 AND 50000      THEN
            'Bajo'
        WHEN total BETWEEN 50001 AND 100000 THEN
            'Medio'
        WHEN total > 100000                 THEN
            'Alto'
    END                                  AS "Categoria",
    CASE codpago
        WHEN 1 THEN
            'EFECTIVO'
        WHEN 2 THEN
            'TARJETA DEBITO'
        WHEN 3 THEN
            'TARJETA CREDITO'
        ELSE
            'CHEQUE'
    END                                  AS "Forma Pago"
FROM
    factura
WHERE
    EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM sysdate) - 1
ORDER BY
    fecha DESC,
    neto DESC;


--- CASO 2 CLIENTES ---

SELECT
    lpad(rutcliente, 12, '*')   AS "RUT",
    nombre                      AS "Cliente",
    nvl(to_char(telefono),
        'Sin telefono')         AS "Telefono",
    nvl(to_char(codcomuna),
        'Sin comuna')           AS "Comuna",
    estado                      AS "Estado",
    CASE
        WHEN ( saldo / credito ) < 0.5               THEN
            'Bueno ('
            || to_char(credito - saldo, '$999G999G999')
            || ')'
        WHEN ( saldo / credito ) BETWEEN 0.5 AND 0.8 THEN
            'Regular ('
            || to_char(credito - saldo, '$999G999G999')
            || ')'
        WHEN ( saldo / credito ) > 0.8               THEN
            'Critico'
    END                         AS "Estado Credito",
    nvl(upper(substr(mail,
                     instr(mail, '@') + 1)),
        'Correo no registrado') AS "Dominio Correo"
FROM
    cliente
WHERE
        estado = 'A'
    AND credito > 0
ORDER BY
    nombre ASC;

--- CASO 3 STOCK ---

SELECT
    codproducto         AS "ID",
    descripcion         AS "Descripcion producto",
    nvl(to_char(valorcompradolar)
        || 'USD',
        'Sin registro') AS "Compra en USD",
    nvl(to_char(round(valorcompradolar * &tipocambio_dolar),
                '$999G999G999')
        || 'PESOS',
        'Sin registro') AS "USD Convertido",
    totalstock          AS "Stock",
    CASE
        WHEN totalstock IS NULL THEN
            'Sin datos'
        WHEN totalstock < &umbral_bajo                         THEN
            '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN &umbral_bajo AND &umbral_alto THEN
            'reabastecer pronto!'
        WHEN totalstock > &umbral_alto                         THEN
            'OK'
    END                 AS "Alerta Stock",
        CASE
        WHEN totalstock > 80 THEN
            to_char(round(vunitario * 0.9),
                    '$999G999G999')
        ELSE
            'N/A'
    END                 AS "Precio Oferta"
FROM
    producto
WHERE
    lower(descripcion) LIKE '%zapato%'
    AND lower(procedencia) = 'i'
ORDER BY
    codproducto DESC;