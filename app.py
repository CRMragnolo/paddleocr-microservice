from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from paddleocr import PaddleOCR
from PIL import Image
import io
import time

app = FastAPI(
    title="PaddleOCR Italian Microservice",
    description="Self-hosted OCR service using PaddleOCR for Italian text extraction",
    version="1.0.0"
)

ocr_instance = None

def get_ocr():
    global ocr_instance
    if ocr_instance is None:
        ocr_instance = PaddleOCR(
            lang='it',
            use_angle_cls=False,
            use_gpu=False,
            show_log=False,
            use_space_char=True,
            drop_score=0.5,
            max_batch_size=1,
            total_process_num=1
        )
    return ocr_instance

@app.get("/")
async def root():
    return {
        "service": "PaddleOCR Italian Microservice",
        "version": "1.0.0",
        "status": "online",
        "cost": "$0 - 100% FREE!",
        "endpoints": {
            "health": "GET /health",
            "ocr": "POST /ocr",
            "ocr_simple": "POST /ocr/simple"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "PaddleOCR Italian OCR",
        "version": "2.9.2",
        "model": "PP-OCRv5 Mobile",
        "language": "it",
        "cost": "$0 - 100% FREE!"
    }

@app.post("/ocr/simple")
async def extract_text_simple(file: UploadFile = File(...)):
    start_time = time.time()
    try:
        contents = await file.read()
        if len(contents) == 0:
            raise HTTPException(status_code=400, detail="Empty file")

        image = Image.open(io.BytesIO(contents))
        max_width = 2000
        if image.width > max_width:
            ratio = max_width / image.width
            new_height = int(image.height * ratio)
            image = image.resize((max_width, new_height), Image.LANCZOS)

        if image.mode != 'RGB':
            image = image.convert('RGB')

        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr.seek(0)

        ocr = get_ocr()
        result = ocr.ocr(img_byte_arr, cls=False)

        if not result or not result[0]:
            return JSONResponse({
                "success": True,
                "text": "",
                "lines": [],
                "cost": "$0 - FREE!",
                "processing_time_ms": int((time.time() - start_time) * 1000)
            })

        all_text = []
        lines = []
        for line in result[0]:
            text = line[1][0]
            confidence = float(line[1][1])
            all_text.append(text)
            lines.append({"text": text, "confidence": round(confidence, 3)})

        return JSONResponse({
            "success": True,
            "text": "\n".join(all_text),
            "lines": lines,
            "cost": "$0 - FREE!",
            "processing_time_ms": int((time.time() - start_time) * 1000)
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR error: {str(e)}")
