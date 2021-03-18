# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from flask import Flask
from flask import request
from flask_cors import CORS
from PIL import Image
import torchvision
import torchvision.transforms as transforms
import torch
import requests

app = Flask(__name__)
CORS(app)
classes = []
with open('classes.txt') as f:
    classes = f.readlines()
    classes = [c.strip() for c in classes]
classes.sort()
print(classes)

inception = torchvision.models.inception_v3(pretrained=True, aux_logits=False)
num_ftrs = inception.fc.in_features
inception.fc = torch.nn.Sequential(
                      torch.nn.Linear(num_ftrs, 101))
loader = transforms.Compose([transforms.Resize((299,299)), transforms.ToTensor()])


def image_loader(image):
    """load image, returns cuda tensor"""
    image = loader(image).float()
    image = torch.autograd.Variable(image, requires_grad=True)
    image = image.unsqueeze(0)  #this is for VGG, may not be needed for ResNet
    return image.to('cpu')  #assumes that you're using GPU

@app.route('/api/infer', methods=['POST'])
def infer():
    src = request.json['src']
    im = Image.open(requests.get(src, stream=True).raw)
    img = image_loader(im)
    inception.load_state_dict(torch.load('./model'))
    inception.eval()
    out = inception(img)
    o = torch.topk(out, 5)
    o = torch.squeeze(o.indices)
    result = ""
    for idx in o:
        print(classes[idx.item()])
        result += classes[idx.item()]+';'
    print(result)
    return result.replace('_', ' ')


if __name__ == "__main__":
    app.run(host='0.0.0.0')