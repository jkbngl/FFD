from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:dhjihdfjdksfhdfhsdfj@35.198.97.21:5433/postgres"
db = SQLAlchemy(app)


class ActDataModel(db.Model):
    __tablename__ = 'act_data'

    id = db.Column(db.Integer, primary_key=True)
    amount = db.Column(db.Float())
    comment = db.Column(db.String())
    data_date = db.Column(db.Date())
    year = db.Column(db.Integer())
    month = db.Column(db.Integer())
    day = db.Column(db.Integer())
    level1_fk = db.Column(db.Integer())
    level1 = db.Column(db.String())
    level2_fk = db.Column(db.Integer())
    level2 = db.Column(db.String())
    level3_fk = db.Column(db.Integer())
    level3 = db.Column(db.String())
    costtype_fk = db.Column(db.Integer())
    costtype = db.Column(db.String())
    user_fk = db.Column(db.String())
    group_fk = db.Column(db.String())
    created = db.Column(db.DateTime())
    updated = db.Column(db.DateTime())
    created_by = db.Column(db.String())
    updated_by = db.Column(db.String())
    active = db.Column(db.Integer())

    def __init__(self, amount, comment, data_date, year, month, day, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype_fk, costtype, user_fk, group_fk, created, updated, created_by, updated_by, active):
        self.amount = amount
        self.comment = comment
        self.data_date = data_date
        self.year = data_date
        self.month = data_date
        self.day = data_date
        self.level1 = level1
        self.level1_fk = level1_fk
        self.level2 = level2
        self.level2_fk = level2_fk
        self.level3 = level3
        self.level3_fk = level3_fk
        self.costtype_fk = costtype_fk
        self.costtype = costtype
        self.user_fk = user_fk
        self.group_fk = group_fk
        self.created = created
        self.updated = updated
        self.created_by = created_by
        self.updated_by = updated_by
        self.active = active

    def __repr__(self):
        return f"<ActData {self.amount} {self.data_date}>"


@app.route('/cars', methods=['POST', 'GET'])
def handle_cars():
    actDatas = ActDataModel.query.all()
    results = [
        {
            "amount": actData.amount,
            "comment": actData.comment,
            "data_date": actData.data_date,
            "year": actData.year,
            "month": actData.month,
            "day": actData.day,
            "level1": actData.level1,
            "level1_fk": actData.level1_fk,
            "level2": actData.level2,
            "level2_fk": actData.level2_fk,
            "level3": actData.level3,
            "level3_fk": actData.level3_fk,
            "costtype_fk": actData.costtype_fk,
            "costtype": actData.costtype,
            "user_fk": actData.user_fk,
            "group_fk": actData.group_fk,
            "created": actData.created,
            "updated": actData.updated,
            "created_by": actData.created_by,
            "updated_by": actData.updated_by,
            "active": actData.active
        } for actData in actDatas]

    return {"count": len(results), "actDatas": actDatas}


if __name__ == '__main__':
    app.run(debug=True)
