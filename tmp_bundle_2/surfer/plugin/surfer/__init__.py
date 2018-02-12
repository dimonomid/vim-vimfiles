
import logging
from os.path import dirname, join


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.disabled = False

logfile = join(dirname(dirname(__file__)), "surfer.log")
handler = logging.FileHandler(logfile, mode="w")
handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(name)s : %(message)s"))
logger.addHandler(handler)
