# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from flask import Flask
from flask import request
from flask_cors import CORS
from PIL import Image
import torch.nn as nn
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
alexnet = torchvision.models.alexnet(pretrained=True)
alexnet.classifier = nn.Sequential(
                      nn.Linear(256*6*6, 1024), 
                        nn.ReLU(),
                        nn.Linear(1024,256),
                        nn.ReLU(),
                      nn.Linear(256, 101))
inception.load_state_dict(torch.load('imodel'))
alexnet.load_state_dict(torch.load('amodel'))
inception.eval()
alexnet.eval()

def image_loader(image):
    """load image, returns cuda tensor"""
    image = loader(image).float()
    image = torch.autograd.Variable(image, requires_grad=True)
    image = image.unsqueeze(0)  #this is for VGG, may not be needed for ResNet
    return image.to('cpu')  #assumes that you're using GPU


def get_max_5(o1, o2):
    o1i, o2i = torch.squeeze(o1.indices).tolist(), torch.squeeze(o2.indices).tolist()
    o1v, o2v = torch.squeeze(o1.values).tolist(), torch.squeeze(o2.values).tolist()
    print(o1v)
    values = {}
    for i in range(len(o1v)):
        if o1v[i] not in values:
            values[o1i[i]] = o1v[i]
    for i in range(len(o2v)):
        if o2i[i] not in values:
            values[o2i[i]] = o2v[i]
        else:
            values[o2i[i]] = o2v[i] if o2v[i] > values[o2i[i]] else values[o2i[i]]
    return sorted(values, key=values.get, reverse=True)[:5]

@app.route('/api/infer', methods=['POST'])
def infer():
    src = request.json['src']
    im = Image.open(requests.get(src, stream=True).raw)
    img = image_loader(im)
    
    inception.eval()
    outputs1 = inception(img)
    outputs2 = alexnet(img)
    o1 = torch.topk(outputs1, 10)
    o2 = torch.topk(outputs2, 10)
    
#     allo = torch.cat((outputs1,outputs2))
#     allo = torch.topk(allo, 5)
    top5 = get_max_5(o1,o2)
#     print(allo)
#     o = torch.squeeze(allo.indices)
    result = ""
#     print(o)
    for idx in top5:
        print(classes[idx])
        result += classes[idx]+';'
    print(result)
    return result.replace('_', ' ')


if __name__ == "__main__":
    app.run(host='0.0.0.0')