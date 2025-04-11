from flask import Blueprint, jsonify, abort, current_app, request
import io


# register the blueprint 
test_routes = Blueprint('test', __name__, url_prefix='/test')


@test_routes.route('/basic')
def basic_test():
    return jsonify("Test successful!"), 200

@test_routes.route('/cover')
def cover_data():
    try:
        query = """
            SELECT ST_AsGeoJSON(ST_simplify("geom", .003))::jsonb FROM cover_poly WHERE "val" > 30 AND "val" < 254""" 

        db_manager = current_app.config['DB_MANAGER']
        result = db_manager.execute_query(query)

        geojson = []
        for r in result:
            geojson.append({
                "type": "Feature",
                "geometry": r[0]
            })

    except Exception as e:
        abort(500, description=str(e))

    return jsonify({
        "type": "FeatureCollection",
        "features": geojson
    }), 200

# Trying to new backend route (to be further tested)
@test_routes.route('/gain')
def gain_test():
    try:
        table_name = "gain_poly"
        query = """
            SELECT ST_AsGeoJSON(ST_simplify("geom", .003))::jsonb, "val" FROM "{}" WHERE val = 1""".format(table_name)
        db_manager = current_app.config['DB_MANAGER']
        result = db_manager.execute_query(query)

        geojson = []
        for r in result:
            geojson.append({
                "type": "Feature",
                "properties": {
                    "value": r[1]
                },
                "geometry": r[0]
            })

    except Exception as e:
        abort(500, description=e)  

    return jsonify({
        "type": "FeatureCollection", "features": geojson
    }), 200

@test_routes.route('/loss')
def loss_test():
    try:
        year = request.args.get('year')
        
        # Check if year is provided and not 2000
        if year is not None and int(year) != 2000:
            # Convert year to val (0 to 22)
            val = int(year) - 2000
            query = """
                SELECT ST_AsGeoJSON(ST_simplify("geom", .003))::jsonb FROM lossyear_poly WHERE "val" = '{}'""".format(val)  
            db_manager = current_app.config['DB_MANAGER']
            result = db_manager.execute_query(query)

            geojson = []
            for r in result:
                geojson.append({
                    "type": "Feature",
                    "geometry": r[0]
                })
        else:
            # Return empty FeatureCollection
            geojson = []

    except Exception as e:
        abort(500, description=e)  

    return jsonify({
        "type": "FeatureCollection", "features": geojson
    }), 200

@test_routes.route('/loss_cumulative')
def loss_cumulative():
    try:
        year = request.args.get('year')
        
        # Check if year is provided and not 2000
        if year is not None and int(year) != 2000:
            # Convert year to val (0 to 22)
            val = int(year) - 2000
            query = """
                SELECT ST_AsGeoJSON(ST_simplify("geom", .003))::jsonb FROM lossyear_poly WHERE "val" <= '{}' AND "val" != 0""".format(val)  
            db_manager = current_app.config['DB_MANAGER']
            result = db_manager.execute_query(query)

            geojson = []
            for r in result:
                geojson.append({
                    "type": "Feature",
                    "geometry": r[0]
                })
        else:
            # Return empty FeatureCollection
            geojson = []

    except Exception as e:
        abort(500, description=e)  

    return jsonify({
        "type": "FeatureCollection", "features": geojson
    }), 200


@test_routes.route('/borders')
def border_test():
    try:
        table_name = "borders"
        query = """
            SELECT ST_AsGeoJSON(ST_simplify("Geo Shape", .003))::jsonb, "English Name" FROM "{}" """.format(table_name)
        db_manager = current_app.config['DB_MANAGER']
        result = db_manager.execute_query(query)

        geojson = []
        for r in result:
            geojson.append({
                "type": "Feature",
                "properties": {
                    "Name": r[1]
                },
                "geometry": r[0]
            })

    except Exception as e:
        abort(500, description=e)  

    return jsonify({
        "type": "FeatureCollection", "features": geojson
    }), 200

#year = request.args.get('year')
@test_routes.route('/country_statistics/<country_name>')
def country_statistics(country_name):
    try:
        year = request.args.get('year')
        query = f"""
            SELECT *, 
            (SELECT SUM(yearly_change_share) FROM fao_stats fs2 WHERE fs2."Area" = fao_stats."Area" AND fs2."Year" <= fao_stats."Year") AS cumulative_year_change_share
            FROM fao_stats 
            WHERE "Area" = '{country_name}'
        """
        if year:
            query += f" AND \"Year\" = '{year}'"

        db_manager = current_app.config['DB_MANAGER']
        result = db_manager.execute_query(query)

        if result:
            # Extracting data from the result
            statistics = {
                "year": result[0][0],
                "countryArea": (result[0][2]) * 10,
                "forestLand": (result[0][3]) * 10,
                "shareForest": result[0][7],
                "shareNRG": result[0][8],
                "sharePlanted": result[0][9],
                "carbonStock": round(result[0][10], 2),
                "co2Removal": round(result[0][11], 2),
                "netConversion": round(result[0][12], 2),
                "landArea": result[0][4],
                "yearChange": result[0][15],
                "cumulativeYearChange": round(result[0][-1], 2)  # Last column is the cumulative year change
            }
        else:
            statistics = None

    except Exception as e:
        abort(500, description=str(e))

    return jsonify(statistics), 200
