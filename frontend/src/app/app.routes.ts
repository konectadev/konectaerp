import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: 'auth',
    loadChildren: () => import('./auth/auth.routes').then(m => m.authRoutes)
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard-routing.module').then(m => m.DashboardRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'hr',
    loadChildren: () => import('./hr/hr-routing.module').then(m => m.HrRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'finance',
    loadChildren: () => import('./finance/finance-routing.module').then(m => m.FinanceRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'inventory',
    loadChildren: () => import('./inventory/inventory-routing.module').then(m => m.InventoryRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
