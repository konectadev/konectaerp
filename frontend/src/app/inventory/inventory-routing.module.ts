import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { InventoryOverviewComponent } from './components/inventory-overview.component';

const routes: Routes = [
  {
    path: '',
    component: InventoryOverviewComponent
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class InventoryRoutingModule { }
