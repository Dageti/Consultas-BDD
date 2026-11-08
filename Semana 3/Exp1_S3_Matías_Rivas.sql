--- CASO 1 ---

SELECT
    id_tipo_propiedad       AS "TIPO",
    COUNT(*)                AS "TOTAL_PROPIEDADES",
    to_char(MAX(valor_arriendo),
            '$999G999G999') AS "MAX_ARRIENDO",
    to_char(round(AVG(valor_arriendo)),
            '$999G999G999') AS "PROMEDIO_ARRIENDO",
    to_char(MIN(valor_arriendo),
            '$999G999G999') AS "MIN_ARRIENDO",
    CASE
        WHEN MAX(valor_arriendo) <= 1000000 THEN
            'ESTÁNDAR'
        ELSE
            'PREMIUM'
    END                     AS "CLASIFICACION",
    to_char(SUM(valor_gasto_comun),
            '$999G999G999') AS "TOTAL_GASTOS_COMUNES"
FROM
    propiedad
GROUP BY
    id_tipo_propiedad
HAVING
    SUM(valor_gasto_comun) > &valor_total_gasto_comun
ORDER BY
    SUM(valor_gasto_comun) DESC;
    
--- CASO 2 ---

SELECT
    upper(nombre_emp
          || ' '
          || appaterno_emp)                               AS "Nombre Empleado",
    to_char(sueldo_emp, '$999G999G999')             AS "Sueldo con Formato",
    CASE
        WHEN sueldo_emp > 2000000 THEN
            'ALTO'
        ELSE
            'MEDIO'
    END                                             AS "Clasificación Sueldo",
    trunc(months_between(sysdate, fecing_emp) / 12) AS "Años Antigüedad",
    CASE
        WHEN trunc(months_between(sysdate, fecing_emp) / 12) BETWEEN 5 AND 10  THEN
            'Corresponde bono  5%: '
            || to_char(round(sueldo_emp * 0.05),
                       '$999G999G999')
        WHEN trunc(months_between(sysdate, fecing_emp) / 12) BETWEEN 11 AND 20 THEN
            'Corresponde bono 10%: '
            || to_char(round(sueldo_emp * 0.10),
                       '$999G999G999')
        WHEN trunc(months_between(sysdate, fecing_emp) / 12) > 20              THEN
            'Corresponde bono 15%: '
            || to_char(round(sueldo_emp * 0.15),
                       '$999G999G999')
    END                                             AS "BONO"
FROM
    empleado
WHERE
        id_categoria_emp = 3
    AND ( months_between(sysdate, fecing_emp) / 12 ) > 5
    AND id_sucursal <> &codigo_sucursal
ORDER BY
    sueldo_emp DESC;
    
--- CASO 3 ---

SELECT
    CASE
        WHEN renta_cli >= 1000000                THEN
            'PREMIUM'
        WHEN renta_cli BETWEEN 600000 AND 999999 THEN
            'ALTA'
        WHEN renta_cli BETWEEN 300000 AND 599999 THEN
            'MEDIA'
        ELSE
            'BAJA'
    END                     AS "CLASIFICACION_RENTA",
    COUNT(*)                AS "CANTIDAD_CLIENTES",
    to_char(round(AVG(renta_cli)),
            '$999G999G999') AS "RENTA_PROMEDIO",
    CASE
        WHEN COUNT(nvl(celular_cli, fonofijo_cli)) > 0 THEN
            'Clientes con Teléfono'
        ELSE
            'Clientes Sin Teléfono'
    END                     AS "ESTADO_TELEFONO"
FROM
    cliente
GROUP BY
    CASE
        WHEN renta_cli >= 1000000                THEN
            'PREMIUM'
        WHEN renta_cli BETWEEN 600000 AND 999999 THEN
            'ALTA'
        WHEN renta_cli BETWEEN 300000 AND 599999 THEN
            'MEDIA'
        ELSE
            'BAJA'
    END
HAVING
    AVG(renta_cli) > 200000;