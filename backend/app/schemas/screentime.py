from pydantic import Basemodel
from typing import Optional
from datetime import datetime

class Screentime(Basemodel):
    minute: int
    