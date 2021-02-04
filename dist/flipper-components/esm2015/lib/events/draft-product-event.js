import { BusEvent } from '@enexus/flipper-event';
export class DraftProductEvent extends BusEvent {
    constructor(draftProduct, action = 'add') {
        super(DraftProductEvent.CHANNEL);
        this.draftProduct = draftProduct;
        this.action = action;
    }
}
DraftProductEvent.CHANNEL = 'draftProduct';
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZHJhZnQtcHJvZHVjdC1ldmVudC5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uLy4uL3Byb2plY3RzL2ZsaXBwZXItY29tcG9uZW50cy9zcmMvbGliL2V2ZW50cy9kcmFmdC1wcm9kdWN0LWV2ZW50LnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE9BQU8sRUFBRSxRQUFRLEVBQUUsTUFBTSx1QkFBdUIsQ0FBQTtBQUdoRCxNQUFNLE9BQU8saUJBQWtCLFNBQVEsUUFBUTtJQUc3QyxZQUFtQixZQUFxQixFQUFTLFNBQWlCLEtBQUs7UUFDckUsS0FBSyxDQUFDLGlCQUFpQixDQUFDLE9BQU8sQ0FBQyxDQUFBO1FBRGYsaUJBQVksR0FBWixZQUFZLENBQVM7UUFBUyxXQUFNLEdBQU4sTUFBTSxDQUFnQjtJQUV2RSxDQUFDOztBQUpzQix5QkFBTyxHQUFHLGNBQWMsQ0FBQSIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IEJ1c0V2ZW50IH0gZnJvbSAnQGVuZXh1cy9mbGlwcGVyLWV2ZW50J1xyXG5pbXBvcnQgeyBQcm9kdWN0IH0gZnJvbSAnLi4vZW50cmllcy9wcm9kdWN0J1xyXG5cclxuZXhwb3J0IGNsYXNzIERyYWZ0UHJvZHVjdEV2ZW50IGV4dGVuZHMgQnVzRXZlbnQge1xyXG4gIHB1YmxpYyBzdGF0aWMgcmVhZG9ubHkgQ0hBTk5FTCA9ICdkcmFmdFByb2R1Y3QnXHJcblxyXG4gIGNvbnN0cnVjdG9yKHB1YmxpYyBkcmFmdFByb2R1Y3Q6IFByb2R1Y3QsIHB1YmxpYyBhY3Rpb246IHN0cmluZyA9ICdhZGQnKSB7XHJcbiAgICBzdXBlcihEcmFmdFByb2R1Y3RFdmVudC5DSEFOTkVMKVxyXG4gIH1cclxufVxyXG4iXX0=