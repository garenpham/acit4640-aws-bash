from db import database as db


class Item(db.Model):
    name = db.Column(db.String(30), nullable=False)
    bcit_id = db.Column(db.String(10), primary_key=True)

    def json(self):
        return {
            "student_name": self.name,
            "student_id": self.bcit_id,
        }
